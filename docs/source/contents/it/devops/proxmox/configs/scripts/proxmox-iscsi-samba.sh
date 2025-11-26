#!/bin/bash

# Proxmox Host iSCSI + SAMBA Setup Script
# Script #1: Connects Proxmox host to NAS via iSCSI with CHAP authentication and sets up SAMBA

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration variables
NAS_IP=""
CHAP_USERNAME=""
CHAP_PASSWORD=""
MOUNT_POINT_HOME="/mnt/nas-home"
MOUNT_POINT_BACKUP="/mnt/nas-backup"
SAMBA_USER=""
SAMBA_PASSWORD=""

# iSCSI targets
ISCSI_TARGET_HOME="iqn.2013-03.com.dlink:sagres:home"
ISCSI_TARGET_BACKUP="iqn.2013-03.com.dlink:sagres:backup"

# Show script description
show_script_description() {
    echo -e "${GREEN}=== Proxmox Host iSCSI + SAMBA Setup Script ===${NC}"
    echo
    echo "This script will configure iSCSI storage and SAMBA sharing:"
    echo
    echo -e "${BLUE}Features:${NC}"
    echo "• Install and configure iSCSI initiator with CHAP authentication"
    echo "• Connect to NAS iSCSI targets (home and backup)"
    echo "• Mount iSCSI storage with persistence"
    echo "• Install and configure SAMBA server for Windows workstation access"
    echo "• Create SAMBA shares for mounted storage"
    echo
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "• Proxmox VE host"
    echo "• NAS with iSCSI targets configured and CHAP authentication"
    echo "• Network connectivity between Proxmox host and NAS"
    echo "• Windows workstations on the same network"
    echo
    read -p "Continue with setup? (Y/n): " continue_setup
    if [[ "$continue_setup" =~ ^[Nn]$ ]]; then
        echo "Setup cancelled by user"
        exit 0
    fi
    echo
}

# Collect configuration
collect_config() {
    echo -e "${BLUE}=== Configuration Setup ===${NC}"
    echo "Please provide all configuration details:"
    echo
    
    read -p "Enter your NAS IP address [sagres.abizi.lan]: " NAS_IP
    read -p "Enter CHAP username [iscsi]: " CHAP_USERNAME
    read -s -p "Enter CHAP password: " CHAP_PASSWORD
    echo
    read -p "Enter home mount point path [/mnt/nas-home]: " MOUNT_POINT_HOME
    read -p "Enter backup mount point path [/mnt/nas-backup]: " MOUNT_POINT_BACKUP
    echo
    echo -e "${BLUE}SAMBA Configuration:${NC}"
    read -p "Enter SAMBA username [admin]: " SAMBA_USER
    read -s -p "Enter SAMBA password: " SAMBA_PASSWORD
    echo
    
    # Use defaults if empty
    if [[ -z "$NAS_IP" ]]; then
        NAS_IP="sagres.abizi.lan"
    fi
    
    if [[ -z "$CHAP_USERNAME" ]]; then
        CHAP_USERNAME="iscsi"
    fi
    
    if [[ -z "$MOUNT_POINT_HOME" ]]; then
        MOUNT_POINT_HOME="/mnt/nas-home"
    fi
    
    if [[ -z "$MOUNT_POINT_BACKUP" ]]; then
        MOUNT_POINT_BACKUP="/mnt/nas-backup"
    fi
    
    if [[ -z "$SAMBA_USER" ]]; then
        SAMBA_USER="admin"
    fi
    
    # Validate required fields
    if [[ -z "$CHAP_PASSWORD" ]]; then
        error "CHAP password is required"
        return 1
    fi
    
    if [[ -z "$SAMBA_PASSWORD" ]]; then
        error "SAMBA password is required"
        return 1
    fi
    
    echo
    log "Configuration summary:"
    log "  NAS IP: $NAS_IP"
    log "  CHAP Username: $CHAP_USERNAME"
    log "  Home Target: $ISCSI_TARGET_HOME"
    log "  Backup Target: $ISCSI_TARGET_BACKUP"
    log "  Home Mount Point: $MOUNT_POINT_HOME"
    log "  Backup Mount Point: $MOUNT_POINT_BACKUP"
    log "  SAMBA User: $SAMBA_USER"
    echo
    read -p "Continue with these settings? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        error "Setup cancelled by user"
        exit 1
    fi
    
    log "Configuration collected"
}

# Install and configure iSCSI
install_iscsi_proxmox() {
    log "Installing iSCSI on Proxmox host..."
    
    apt update
    apt install -y open-iscsi
    
    # Load kernel modules
    modprobe iscsi_tcp
    modprobe libiscsi
    modprobe scsi_transport_iscsi
    
    # Make modules persistent
    cat > /etc/modules-load.d/iscsi.conf << EOF
iscsi_tcp
libiscsi
scsi_transport_iscsi
EOF
    
    # Start services
    systemctl start iscsid
    systemctl enable iscsid
    systemctl start open-iscsi
    systemctl enable open-iscsi
    
    log "iSCSI installed and started on Proxmox host"
}

# Configure CHAP authentication
configure_chap_proxmox() {
    log "Configuring CHAP authentication on Proxmox host..."
    
    # Backup original configuration
    cp /etc/iscsi/iscsid.conf /etc/iscsi/iscsid.conf.backup-$(date +%Y%m%d-%H%M%S)
    
    # Add CHAP configuration
    cat >> /etc/iscsi/iscsid.conf << EOF

# CHAP Settings for NAS authentication
node.session.auth.authmethod = CHAP
node.session.auth.username = $CHAP_USERNAME
node.session.auth.password = $CHAP_PASSWORD

discovery.sendtargets.auth.authmethod = CHAP
discovery.sendtargets.auth.username = $CHAP_USERNAME
discovery.sendtargets.auth.password = $CHAP_PASSWORD
EOF

    # Restart iscsid to load new configuration
    systemctl restart iscsid
    
    log "CHAP authentication configured"
}

# Connect to iSCSI target
connect_iscsi_target() {
    local target_iqn="$1"
    local target_name="$2"
    
    log "Connecting to iSCSI target: $target_iqn ($target_name)"
    
    # Check if target is already connected
    if iscsiadm -m session 2>/dev/null | grep -q "$target_iqn"; then
        log "✓ Target $target_iqn is already connected"
        return 0
    fi
    
    # Create the node entry for the target
    log "Creating node entry for target..."
    if ! iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -o new 2>/dev/null; then
        warn "Node entry may already exist, continuing..."
    fi
    
    # Configure session CHAP for the target
    log "Configuring CHAP authentication for target..."
    iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -o update -n node.session.auth.authmethod -v CHAP 2>/dev/null || warn "Could not update auth method"
    iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -o update -n node.session.auth.username -v "$CHAP_USERNAME" 2>/dev/null || warn "Could not update username"
    iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -o update -n node.session.auth.password -v "$CHAP_PASSWORD" 2>/dev/null || warn "Could not update password"
    
    # Make connection persistent
    iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -o update -n node.startup -v automatic 2>/dev/null || warn "Could not set startup mode"
    
    # Connect to target
    if ! iscsiadm -m node -T "$target_iqn" -p "$NAS_IP:3260" -l; then
        if iscsiadm -m session 2>/dev/null | grep -q "$target_iqn"; then
            log "✓ Target was already connected"
        else
            error "Failed to login to target: $target_iqn"
            return 1
        fi
    fi
    
    # Wait for device to appear
    sleep 5
    
    log "✓ Connected to iSCSI target $target_name successfully"
}

# Setup disk and mount point
setup_disk_and_mount() {
    local mount_point="$1"
    local target_name="$2"
    
    log "Setting up disk and mount point for $target_name..."
    
    echo -e "${BLUE}Available block devices:${NC}"
    lsblk
    
    # Auto-detect the iSCSI disk
    local iscsi_disk=""
    local potential_disks
    potential_disks=$(lsblk -ndo NAME,SIZE | grep -E "(T|G)" | awk '{if($2 ~ /T$/) print $1}' | tail -2)
    
    if [[ -n "$potential_disks" ]]; then
        echo -e "${BLUE}Potential iSCSI disks:${NC}"
        echo "$potential_disks"
        read -p "Enter the device path for $target_name (e.g., /dev/sdd): " DEVICE
    else
        read -p "Enter the iSCSI device path for $target_name (e.g., /dev/sdd): " DEVICE
    fi
    
    if [[ ! -b "$DEVICE" ]]; then
        error "Device $DEVICE does not exist!"
        return 1
    fi
    
    log "Using device: $DEVICE for $target_name"
    
    # Check existing partitions
    echo -e "${BLUE}Partitions on $DEVICE:${NC}"
    lsblk "$DEVICE"
    
    # Determine which partition to use
    local main_partition=""
    local partitions
    partitions=$(lsblk -nr "$DEVICE" | grep part | awk '{print $1}' | head -1)
    
    if [[ -n "$partitions" ]]; then
        main_partition="/dev/$partitions"
        log "Using partition: $main_partition"
    else
        main_partition="$DEVICE"
        log "Using whole device: $main_partition"
    fi
    
    # Create mount point and mount
    mkdir -p "$mount_point"
    
    # Check if partition is already mounted
    if mount | grep -q "$main_partition"; then
        warn "Partition $main_partition is already mounted"
        local existing_mount
        existing_mount=$(mount | grep "$main_partition" | awk '{print $3}')
        log "Currently mounted at: $existing_mount"
        
        if [[ "$existing_mount" != "$mount_point" ]]; then
            read -p "Remount to $mount_point? (y/N): " remount_choice
            if [[ "$remount_choice" =~ ^[Yy]$ ]]; then
                umount "$main_partition"
                mount "$main_partition" "$mount_point"
            else
                mount_point="$existing_mount"
                log "Using existing mount point: $mount_point"
            fi
        fi
    else
        # Try to mount
        if mount "$main_partition" "$mount_point"; then
            log "Mounted $main_partition to $mount_point"
        else
            error "Failed to mount $main_partition"
            return 1
        fi
    fi
    
    # Add to fstab for persistence
    local uuid
    uuid=$(blkid -s UUID -o value "$main_partition")
    
    if [[ -n "$uuid" ]]; then
        if ! grep -q "$uuid" /etc/fstab; then
            local fstype
            fstype=$(blkid -s TYPE -o value "$main_partition")
            echo "UUID=$uuid $mount_point $fstype defaults,_netdev 0 0" >> /etc/fstab
            log "Added to fstab with UUID: $uuid"
        else
            log "Already exists in fstab"
        fi
    fi
    
    log "Disk setup completed for $target_name at $mount_point"
}

# Install and configure SAMBA
install_configure_samba() {
    log "Installing and configuring SAMBA server..."
    
    # Install SAMBA
    apt update
    apt install -y samba samba-common-bin
    
    # Backup original configuration
    cp /etc/samba/smb.conf /etc/samba/smb.conf.backup-$(date +%Y%m%d-%H%M%S)
    
    # Create SAMBA configuration
    cat > /etc/samba/smb.conf << EOF
[global]
   workgroup = WORKGROUP
   server string = Proxmox NAS Server
   netbios name = PROXMOX-NAS
   security = user
   map to guest = bad user
   dns proxy = no
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   
   # Performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
   use sendfile = yes
   
   # Security
   client min protocol = SMB2
   server min protocol = SMB2

[nas-home]
   comment = NAS Home Storage
   path = $MOUNT_POINT_HOME
   browseable = yes
   writable = yes
   guest ok = no
   valid users = $SAMBA_USER
   create mask = 0664
   directory mask = 0775
   force user = root
   force group = root

[nas-backup]
   comment = NAS Backup Storage
   path = $MOUNT_POINT_BACKUP
   browseable = yes
   writable = yes
   guest ok = no
   valid users = $SAMBA_USER
   create mask = 0664
   directory mask = 0775
   force user = root
   force group = root
EOF

    # Create SAMBA user
    log "Creating SAMBA user: $SAMBA_USER"
    
    # Create system user if it doesn't exist
    if ! id "$SAMBA_USER" &>/dev/null; then
        useradd -r -s /bin/false "$SAMBA_USER"
    fi
    
    # Add SAMBA user
    echo -e "$SAMBA_PASSWORD\n$SAMBA_PASSWORD" | smbpasswd -a "$SAMBA_USER"
    smbpasswd -e "$SAMBA_USER"
    
    # Enable and start SAMBA services
    systemctl enable smbd
    systemctl enable nmbd
    systemctl start smbd
    systemctl start nmbd
    
    # Configure firewall if UFW is active
    if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
        log "Configuring firewall for SAMBA..."
        ufw allow samba
    fi
    
    log "SAMBA server configured and started"
    
    echo -e "${BLUE}SAMBA Share Information:${NC}"
    echo "Server: \\\\$(hostname -I | awk '{print $1}')"
    echo "Shares:"
    echo "  \\\\$(hostname -I | awk '{print $1}')\\nas-home"
    echo "  \\\\$(hostname -I | awk '{print $1}')\\nas-backup"
    echo "Username: $SAMBA_USER"
}

# Test the setup
test_setup() {
    log "Testing the complete setup..."
    
    # Test iSCSI sessions
    echo -e "${BLUE}iSCSI Sessions:${NC}"
    iscsiadm -m session
    
    # Test mounts
    echo -e "${BLUE}Mount Status:${NC}"
    df -h | grep -E "(Filesystem|nas-home|nas-backup)"
    
    # Test SAMBA
    echo -e "${BLUE}SAMBA Status:${NC}"
    systemctl status smbd --no-pager -l
    
    # Show SAMBA shares
    echo -e "${BLUE}SAMBA Shares:${NC}"
    smbclient -L localhost -U "$SAMBA_USER%$SAMBA_PASSWORD" 2>/dev/null || warn "Could not list SAMBA shares"
    
    log "Setup tests completed"
}

# Display final summary
show_summary() {
    echo
    echo -e "${GREEN}=== Proxmox Host iSCSI + SAMBA Setup Complete ===${NC}"
    echo "NAS IP: $NAS_IP"
    echo "Home Target: $ISCSI_TARGET_HOME"
    echo "Backup Target: $ISCSI_TARGET_BACKUP"
    echo "Home Mount: $MOUNT_POINT_HOME"
    echo "Backup Mount: $MOUNT_POINT_BACKUP"
    echo "SAMBA User: $SAMBA_USER"
    echo
    echo -e "${BLUE}Windows Access:${NC}"
    echo "Server: \\\\$(hostname -I | awk '{print $1}')"
    echo "Home Share: \\\\$(hostname -I | awk '{print $1}')\\nas-home"
    echo "Backup Share: \\\\$(hostname -I | awk '{print $1}')\\nas-backup"
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Test Windows access to SAMBA shares"
    echo "2. Configure backup scripts to use $MOUNT_POINT_BACKUP"
    echo "3. Set up regular maintenance tasks"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "Check iSCSI: iscsiadm -m session"
    echo "Check mounts: df -h | grep nas"
    echo "Check SAMBA: systemctl status smbd"
    echo "List shares: smbclient -L localhost -U $SAMBA_USER"
}

# Main function
main() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root on the Proxmox host"
        exit 1
    fi
    
    # Check if we're on Proxmox
    if [[ ! -d "/etc/pve" ]]; then
        error "This script must be run on a Proxmox host"
        exit 1
    fi
    
    show_script_description
    collect_config
    install_iscsi_proxmox
    configure_chap_proxmox
    
    # Connect to both iSCSI targets
    connect_iscsi_target "$ISCSI_TARGET_HOME" "home"
    connect_iscsi_target "$ISCSI_TARGET_BACKUP" "backup"
    
    # Setup mounts for both targets
    setup_disk_and_mount "$MOUNT_POINT_HOME" "home"
    setup_disk_and_mount "$MOUNT_POINT_BACKUP" "backup"
    
    install_configure_samba
    test_setup
    show_summary
    
    log "Proxmox host iSCSI + SAMBA setup completed successfully!"
}

# Run main function
main "$@"

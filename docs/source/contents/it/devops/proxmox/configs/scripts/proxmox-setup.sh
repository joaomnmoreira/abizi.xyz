#!/bin/bash

# Proxmox Host iSCSI Setup Script with LXC Bind Mount
# Run this script on the PROXMOX HOST (not in LXC container)

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to get NFS folder selection
get_nfs_folders() {
    echo -e "${BLUE}NFS Folder Selection:${NC}"
    echo "Select which folders under MULTIMEDIA should be shared via NFS for Kodi access:"
    echo
    echo "Available options:"
    echo "1. Filmes (Movies)"
    echo "2. Musica (Music)" 
    echo "3. Series (TV Shows)"
    echo "4. Documentarios (Documentaries)"
    echo "5. Custom folder name"
    echo
    echo "Enter folder names separated by spaces (e.g., 'Filmes Musica Series')"
    read -p "NFS folders to share [Filmes Musica]: " NFS_FOLDERS
    
    # Use default if empty
    if [[ -z "$NFS_FOLDERS" ]]; then
        NFS_FOLDERS="Filmes Musica"
    fi
    
    log "Selected NFS folders: $NFS_FOLDERS"
}

# Show script description
show_script_description() {
    echo -e "${GREEN}=== Proxmox Host iSCSI + NFS Setup Script ===${NC}"
    echo
    echo "This script will configure a complete iSCSI storage solution with NFS sharing:"
    echo
    echo -e "${BLUE}On PROXMOX HOST, this script will:${NC}"
    echo "• Install and configure iSCSI initiator with CHAP authentication"
    echo "• Connect to your NAS iSCSI target and mount the storage"
    echo "• Install and configure NFS server"
    echo "• Create NFS exports for media folders (accessible by Kodi)"
    echo "• Configure proper filesystem permissions and mount persistence"
    echo
    echo -e "${BLUE}On LXC CONTAINER, this script will:${NC}"
    echo "• Configure bind mount to access the iSCSI storage"
    echo "• Set up UID/GID mapping for unprivileged container permissions"
    echo "• Enable Docker containers to read/write to NAS storage"
    echo "• Create proper directory structure for media automation"
    echo
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "• Proxmox VE host with LXC container running Docker/Portainer"
    echo "• NAS with iSCSI target configured and CHAP authentication"
    echo "• Network connectivity between Proxmox host and NAS"
    echo "• Kodi device on the same network for NFS access"
    echo
    read -p "Continue with setup? (Y/n): " continue_setup
    if [[ "$continue_setup" =~ ^[Nn]$ ]]; then
        echo "Setup cancelled by user"
        exit 0
    fi
    echo
}

# Function to get user selection
get_docker_user_id() {
    # Check if LXC_CONTAINER_ID is set
    if [[ -z "$LXC_CONTAINER_ID" ]]; then
        error "LXC Container ID not set. This is a script error."
        return 1
    fi
    
    echo -e "${BLUE}Available users for Docker containers:${NC}"
    echo
    
    # Check if container is running first
    log "Checking LXC container $LXC_CONTAINER_ID status..."
    if ! pct status "$LXC_CONTAINER_ID" >/dev/null 2>&1; then
        error "LXC container $LXC_CONTAINER_ID does not exist"
        return 1
    fi
    
    local container_status
    container_status=$(pct status "$LXC_CONTAINER_ID" | awk '{print $2}')
    if [[ "$container_status" != "running" ]]; then
        error "LXC container $LXC_CONTAINER_ID is not running (status: $container_status)"
        echo "Please start the container first: pct start $LXC_CONTAINER_ID"
        return 1
    fi
    
    # Get users from the LXC container
    log "Getting users from LXC container $LXC_CONTAINER_ID..."
    local lxc_users
    if lxc_users=$(pct exec "$LXC_CONTAINER_ID" -- getent passwd 2>/dev/null); then
        # Filter for users with UID >= 1000 and < 65534
        local filtered_users
        filtered_users=$(echo "$lxc_users" | awk -F: '$3 >= 1000 && $3 < 65534' | sort -t: -k3 -n)
        
        if [[ -n "$filtered_users" ]]; then
            echo "Users from LXC container $LXC_CONTAINER_ID:"
            echo "UID    Username         Description"
            echo "----   --------         -----------"
            echo "$filtered_users" | while IFS=':' read -r username x uid gid description homedir shell; do
                printf "%-6s %-16s %s\n" "$uid" "$username" "$description"
            done
        else
            error "No users with UID 1000+ found in LXC container $LXC_CONTAINER_ID"
            echo "Expected to find Docker service users like radarr, transmission, etc."
            echo "Please create the necessary users in your container first, or check container ID."
            echo ""
            echo "To create users manually:"
            echo "pct exec $LXC_CONTAINER_ID -- useradd -u 1000 -m radarr"
            echo "pct exec $LXC_CONTAINER_ID -- useradd -u 1001 -m transmission" 
            echo "pct exec $LXC_CONTAINER_ID -- useradd -u 1002 -m arr-stack"
            return 1
        fi
    else
        error "Could not execute commands in LXC container $LXC_CONTAINER_ID"
        echo "This could be due to:"
        echo "1. Container not fully started yet"
        echo "2. Permission issues"
        echo "3. Container filesystem problems"
        echo ""
        echo "Try: pct exec $LXC_CONTAINER_ID -- echo 'test'"
        return 1
    fi
    
    echo
    echo "Note: Select the UID that matches your Docker Compose PUID configuration"
    echo
    
    read -p "Enter the UID for Docker Compose Stack [1002]: " DOCKER_USER_ID
    
    # Use default if empty
    if [[ -z "$DOCKER_USER_ID" ]]; then
        DOCKER_USER_ID="1002"
    fi
    
    # Validate it's a number
    if ! [[ "$DOCKER_USER_ID" =~ ^[0-9]+$ ]]; then
        error "Invalid UID: $DOCKER_USER_ID (must be a number)"
        return 1
    fi
    
    # Validate it's in reasonable range
    if [[ "$DOCKER_USER_ID" -lt 100 || "$DOCKER_USER_ID" -gt 65533 ]]; then
        error "UID out of reasonable range: $DOCKER_USER_ID (should be 100-65533)"
        return 1
    fi
    
    # Check if the UID exists in LXC container and show username
    if pct exec "$LXC_CONTAINER_ID" -- getent passwd "$DOCKER_USER_ID" >/dev/null 2>&1; then
        local username
        username=$(pct exec "$LXC_CONTAINER_ID" -- getent passwd "$DOCKER_USER_ID" | cut -d: -f1)
        log "Selected Docker user ID: $DOCKER_USER_ID (username: $username in container)"
    else
        error "Selected Docker user ID: $DOCKER_USER_ID does not exist in container"
        echo "Please select a UID from the list above or create the user first"
        return 1
    fi
}

# Configuration variables
NAS_IP=""
ISCSI_TARGET=""
CHAP_USERNAME=""
CHAP_PASSWORD=""
MOUNT_POINT="/mnt/nas-library"
LXC_CONTAINER_ID=""

# Collect configuration
collect_config() {
    echo -e "${BLUE}=== Configuration Setup ===${NC}"
    echo "Please provide all configuration details:"
    echo
    
    read -p "Enter your NAS IP address [sagres.abizi.lan]: " NAS_IP
    read -p "Enter CHAP username [iscsi]: " CHAP_USERNAME
    read -s -p "Enter CHAP password: " CHAP_PASSWORD
    echo
    read -p "Enter iSCSI target IQN [iqn.2013-03.com.dlink:sagres:home]: " ISCSI_TARGET
    read -p "Enter mount point path [/mnt/nas-library]: " MOUNT_POINT
    read -p "Enter LXC Container ID (where Docker runs) [23001]: " LXC_CONTAINER_ID
    read -p "Enter Kodi/NFS client IP address [192.168.8.15]: " KODI_IP
    
    # Use defaults if empty (set these first)
    if [[ -z "$NAS_IP" ]]; then
        NAS_IP="sagres.abizi.lan"
    fi
    
    if [[ -z "$CHAP_USERNAME" ]]; then
        CHAP_USERNAME="iscsi"
    fi
    
    if [[ -z "$ISCSI_TARGET" ]]; then
        ISCSI_TARGET="iqn.2013-03.com.dlink:sagres:home"
    fi
    
    if [[ -z "$MOUNT_POINT" ]]; then
        MOUNT_POINT="/mnt/nas-library"
    fi
    
    if [[ -z "$LXC_CONTAINER_ID" ]]; then
        LXC_CONTAINER_ID="23001"
    fi
    
    if [[ -z "$KODI_IP" ]]; then
        KODI_IP="192.168.8.15"
    fi
    
    # Validate required fields
    if [[ -z "$CHAP_PASSWORD" ]]; then
        error "CHAP password is required"
        return 1
    fi
    
    echo
    # Get NFS folder selection
    get_nfs_folders
    
    echo
    # Get Docker user ID (now LXC_CONTAINER_ID is set)
    get_docker_user_id || return 1
    
    echo
    log "Configuration summary:"
    log "  NAS IP: $NAS_IP"
    log "  CHAP Username: $CHAP_USERNAME"
    log "  iSCSI Target: $ISCSI_TARGET"
    log "  Mount Point: $MOUNT_POINT"
    log "  LXC Container ID: $LXC_CONTAINER_ID"
    log "  Kodi IP: $KODI_IP"
    log "  Docker User ID: $DOCKER_USER_ID"
    log "  NFS Folders: $NFS_FOLDERS"
    echo
    read -p "Continue with these settings? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        error "Setup cancelled by user"
        exit 1
    fi
    
    log "Configuration collected"
}

# Install and configure NFS server
install_configure_nfs() {
    log "Installing and configuring NFS server on Proxmox host..."
    
    # Install NFS server
    apt update
    apt install -y nfs-kernel-server
    
    # Enable and start NFS services
    systemctl enable nfs-kernel-server
    systemctl enable rpcbind
    systemctl start rpcbind
    systemctl start nfs-kernel-server
    
    log "NFS server installed and started"
    
    # Create NFS exports configuration
    log "Configuring NFS exports..."
    
    # Backup existing exports
    if [[ -f "/etc/exports" ]]; then
        cp /etc/exports /etc/exports.backup-$(date +%Y%m%d-%H%M%S)
    fi
    
    # Create exports for selected folders
    for folder in $NFS_FOLDERS; do
        local folder_path="$MOUNT_POINT/MULTIMEDIA/$folder"
        local export_line="$folder_path $KODI_IP(rw,sync,no_subtree_check,nohide,all_squash,anonuid=$DOCKER_USER_ID,anongid=$DOCKER_USER_ID,insecure)"
        
        # Create folder if it doesn't exist
        if [[ ! -d "$folder_path" ]]; then
            log "Creating NFS export folder: $folder_path"
            mkdir -p "$folder_path"
            chown $DOCKER_USER_ID:$DOCKER_USER_ID "$folder_path"
        fi
        
        # Check if export already exists in /etc/exports
        if grep -qF "$folder_path $KODI_IP" /etc/exports 2>/dev/null; then
            log "Export already exists: $folder_path -> $KODI_IP (skipping)"
        else
            # Add export configuration
            echo "$export_line" >> /etc/exports
            log "Added NFS export: $folder_path -> $KODI_IP"
        fi
    done
    
    log "NFS exports configuration:"
    cat /etc/exports | grep -E "(Filmes|Musica|Series|Documentarios)" || echo "No media exports found"
    
    # Export the NFS shares
    exportfs -ra
    
    # Show active exports
    echo -e "${BLUE}Active NFS exports:${NC}"
    showmount -e localhost 2>/dev/null || warn "Could not show NFS exports"
    
    # Configure firewall if UFW is active
    if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
        log "Configuring firewall for NFS..."
        ufw allow from $KODI_IP to any port nfs
        ufw allow from $KODI_IP to any port 111
        ufw allow from $KODI_IP to any port 2049
    fi
    
    log "NFS server configuration completed"
    
    echo -e "${BLUE}Kodi NFS mount information:${NC}"
    echo "Server IP: $(hostname -I | awk '{print $1}')"
    echo "NFS Paths for Kodi:"
    for folder in $NFS_FOLDERS; do
        echo "  $folder: nfs://$(hostname -I | awk '{print $1}')$MOUNT_POINT/MULTIMEDIA/$folder"
    done
}
install_iscsi_proxmox() {
    log "Installing iSCSI on Proxmox host..."
    
    apt update
    apt install -y open-iscsi
    
    # Load kernel modules (should work fine on Proxmox host)
    modprobe iscsi_tcp
    modprobe libiscsi
    modprobe scsi_transport_iscsi
    
    # Make modules persistent
    cat > /etc/modules-load.d/iscsi.conf << EOF
iscsi_tcp
libiscsi
scsi_transport_iscsi
EOF
    
    # Start services (should work without mlockall issues)
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
    cp /etc/iscsi/iscsid.conf /etc/iscsi/iscsid.conf.backup
    
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

# Discover and connect to iSCSI target
discover_and_connect() {
    # Since we already have the target IQN from config, skip discovery and connect directly
    log "Connecting to iSCSI target: $ISCSI_TARGET"
    
    # Test if iscsid is working properly
    if ! iscsiadm -V &>/dev/null; then
        error "iscsiadm is not working on Proxmox host"
        return 1
    fi
    
    # Check if target is already connected
    if iscsiadm -m session 2>/dev/null | grep -q "$ISCSI_TARGET"; then
        log "✓ Target $ISCSI_TARGET is already connected"
        log "Current session information:"
        iscsiadm -m session | grep "$ISCSI_TARGET"
        log "Proceeding to disk configuration..."
        return 0
    fi
    
    # Create the node entry for the target
    log "Creating node entry for target..."
    if ! iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -o new 2>/dev/null; then
        warn "Node entry may already exist, continuing..."
    fi
    
    # Configure session CHAP for the target
    log "Configuring CHAP authentication for target..."
    iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -o update -n node.session.auth.authmethod -v CHAP 2>/dev/null || warn "Could not update auth method"
    iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -o update -n node.session.auth.username -v "$CHAP_USERNAME" 2>/dev/null || warn "Could not update username"
    iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -o update -n node.session.auth.password -v "$CHAP_PASSWORD" 2>/dev/null || warn "Could not update password"
    
    # Make connection persistent
    iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -o update -n node.startup -v automatic 2>/dev/null || warn "Could not set startup mode"
    
    # Connect to target
    if ! iscsiadm -m node -T "$ISCSI_TARGET" -p "$NAS_IP:3260" -l; then
        # Check if it's already connected
        if iscsiadm -m session 2>/dev/null | grep -q "$ISCSI_TARGET"; then
            log "✓ Target was already connected"
        else
            error "Failed to login to target: $ISCSI_TARGET"
            echo "This could be due to:"
            echo "1. Incorrect CHAP credentials for session authentication"
            echo "2. Target not accessible or offline"  
            echo "3. Network connectivity issues"
            echo ""
            echo "Please verify:"
            echo "- NAS IP: $NAS_IP is reachable"
            echo "- CHAP credentials are correct"
            echo "- Target IQN: $ISCSI_TARGET is correct"
            return 1
        fi
    fi
    
    # Wait for device to appear
    sleep 5
    
    log "✓ Connected to iSCSI target successfully"
    
    # Show session status
    echo -e "${BLUE}iSCSI Session:${NC}"
    iscsiadm -m session
    
    log "iSCSI connection established successfully"
}

# Setup disk and mount point
setup_disk_and_mount() {
    log "Setting up disk and mount point..."
    
    echo -e "${BLUE}Available block devices:${NC}"
    lsblk
    
    echo -e "\n${BLUE}iSCSI session information:${NC}"
    iscsiadm -m session -P 3 | grep -E "(Target:|Current Portal:|Attached scsi disk)"
    
    echo -e "\n${BLUE}Recent disk additions:${NC}"
    dmesg | tail -15 | grep -i "scsi\|disk" || echo "No recent disk messages"
    
    # Try to auto-detect the iSCSI disk
    local iscsi_disk=""
    local potential_disks
    potential_disks=$(lsblk -ndo NAME,SIZE | grep -E "(T|G)" | awk '{if($2 ~ /T$/) print $1}' | tail -1)
    
    if [[ -n "$potential_disks" ]]; then
        log "Detected potential iSCSI disk: /dev/$potential_disks"
        read -p "Is /dev/$potential_disks your iSCSI disk? (Y/n): " confirm_disk
        if [[ "$confirm_disk" =~ ^[Nn]$ ]]; then
            read -p "Enter the correct iSCSI device path (e.g., /dev/sdd): " DEVICE
        else
            DEVICE="/dev/$potential_disks"
        fi
    else
        read -p "Enter the iSCSI device path (e.g., /dev/sdd): " DEVICE
    fi
    
    if [[ ! -b "$DEVICE" ]]; then
        error "Device $DEVICE does not exist!"
        return 1
    fi
    
    log "Using device: $DEVICE"
    
    # Check existing partitions
    echo -e "${BLUE}Partitions on $DEVICE:${NC}"
    lsblk "$DEVICE"
    
    # Determine which partition to use
    local main_partition=""
    local partitions
    partitions=$(lsblk -nr "$DEVICE" | grep part | awk '{print $1}' | grep -v "${DEVICE##*/}9$")
    
    if [[ $(echo "$partitions" | wc -l) -eq 1 ]]; then
        main_partition="/dev/$(echo "$partitions" | head -1)"
        log "Found single main partition: $main_partition"
    elif [[ $(echo "$partitions" | wc -l) -gt 1 ]]; then
        echo -e "${BLUE}Multiple partitions found:${NC}"
        lsblk "$DEVICE" -f
        echo
        
        # Try to identify the largest data partition
        local largest_part
        largest_part=$(lsblk -bnr "$DEVICE" | grep part | sort -k4 -nr | head -1 | awk '{print $1}')
        
        if [[ -n "$largest_part" ]]; then
            main_partition="/dev/$largest_part"
            log "Auto-selected largest partition: $main_partition"
            read -p "Use $main_partition? (Y/n): " confirm_part
            if [[ "$confirm_part" =~ ^[Nn]$ ]]; then
                read -p "Enter the partition to use (e.g., ${DEVICE}2): " main_partition
            fi
        else
            read -p "Enter the partition to use for mounting (e.g., ${DEVICE}2): " main_partition
        fi
    else
        warn "No partitions found on $DEVICE"
        read -p "Format this device with a new partition? (y/N): " format_choice
        if [[ "$format_choice" =~ ^[Yy]$ ]]; then
            warn "This will DESTROY ALL DATA on $DEVICE!"
            read -p "Type 'YES' to confirm: " confirm
            if [[ "$confirm" == "YES" ]]; then
                log "Creating partition table and formatting..."
                parted -s "$DEVICE" mklabel msdos
                parted -s "$DEVICE" mkpart primary ext4 0% 100%
                sleep 2
                mkfs.ext4 -F "${DEVICE}1"
                main_partition="${DEVICE}1"
                log "Device formatted with ext4"
            else
                error "Formatting cancelled"
                return 1
            fi
        else
            error "Cannot proceed without a usable partition"
            return 1
        fi
    fi
    
    if [[ ! -b "$main_partition" ]]; then
        error "Partition $main_partition does not exist!"
        return 1
    fi
    
    log "Using partition: $main_partition"
    
    # Create mount point and mount
    mkdir -p $MOUNT_POINT
    
    # Check if partition is already mounted
    if mount | grep -q "$main_partition"; then
        warn "Partition $main_partition is already mounted"
        local existing_mount
        existing_mount=$(mount | grep "$main_partition" | awk '{print $3}')
        log "Currently mounted at: $existing_mount"
        
        if [[ "$existing_mount" != "$MOUNT_POINT" ]]; then
            read -p "Remount to $MOUNT_POINT? (y/N): " remount_choice
            if [[ "$remount_choice" =~ ^[Yy]$ ]]; then
                umount "$main_partition"
                mount "$main_partition" $MOUNT_POINT
            else
                MOUNT_POINT="$existing_mount"
                log "Using existing mount point: $MOUNT_POINT"
            fi
        fi
    else
        # Try to mount
        if mount "$main_partition" $MOUNT_POINT; then
            log "Mounted $main_partition to $MOUNT_POINT"
        else
            # Try mounting with read-write explicitly
            if mount -o rw "$main_partition" $MOUNT_POINT; then
                log "Mounted $main_partition to $MOUNT_POINT with explicit read-write"
            else
                error "Failed to mount $main_partition"
                return 1
            fi
        fi
    fi
    
    # Add to fstab for persistence
    local uuid
    uuid=$(blkid -s UUID -o value "$main_partition")
    
    if [[ -n "$uuid" ]]; then
        # Check if already in fstab
        if ! grep -q "$uuid" /etc/fstab; then
            # Detect filesystem type and add appropriate mount options
            local fstype
            fstype=$(blkid -s TYPE -o value "$main_partition")
            if [[ "$fstype" == "ntfs" ]]; then
                echo "UUID=$uuid $MOUNT_POINT ntfs-3g rw,uid=$DOCKER_USER_ID,gid=$DOCKER_USER_ID,umask=0022,force,_netdev 0 0" >> /etc/fstab
                log "Added to fstab as NTFS with UUID: $uuid (uid=$DOCKER_USER_ID)"
            else
                echo "UUID=$uuid $MOUNT_POINT $fstype defaults,_netdev 0 0" >> /etc/fstab
                log "Added to fstab with UUID: $uuid"
            fi
        else
            log "Already exists in fstab"
        fi
    else
        warn "Could not get UUID, adding device path to fstab"
        if ! grep -q "$main_partition" /etc/fstab; then
            echo "$main_partition $MOUNT_POINT auto defaults,_netdev 0 0" >> /etc/fstab
        fi
    fi
    
    # Show what's currently on the disk
    echo -e "${BLUE}Current contents of $MOUNT_POINT:${NC}"
    ls -la $MOUNT_POINT/
    
    # Check if we can write to the mount point
    if [[ ! -w "$MOUNT_POINT" ]]; then
        error "Mount point is read-only. Attempting to remount with write permissions..."
        if mount -o remount,rw "$MOUNT_POINT"; then
            log "Successfully remounted with write permissions"
        else
            error "Failed to remount with write permissions"
            echo "You may need to:"
            echo "1. Check disk errors: fsck $main_partition"
            echo "2. Unmount and remount: umount $MOUNT_POINT && mount -o rw $main_partition $MOUNT_POINT"
            return 1
        fi
    fi
    
    # Check for existing MULTIMEDIA directory and use it
    if [[ -d "$MOUNT_POINT/MULTIMEDIA" ]]; then
        log "Found existing MULTIMEDIA directory"
        
        # Check for existing Filmes and Downloads directories
        echo -e "${BLUE}Existing MULTIMEDIA structure:${NC}"
        ls -la "$MOUNT_POINT/MULTIMEDIA/" 2>/dev/null || echo "Could not list MULTIMEDIA contents"
        
        # Set up directory structure based on existing folders
        local filmes_dir="$MOUNT_POINT/MULTIMEDIA/Filmes"
        local downloads_dir="$MOUNT_POINT/MULTIMEDIA/Downloads"
        
        # Create directories if they don't exist
        if [[ ! -d "$filmes_dir" ]]; then
            log "Creating Filmes directory..."
            mkdir -p "$filmes_dir" 2>/dev/null || warn "Could not create Filmes directory"
        else
            log "Found existing Filmes directory"
        fi
        
        if [[ ! -d "$downloads_dir" ]]; then
            log "Creating Downloads directory structure..."
            mkdir -p "$downloads_dir"/{complete,incomplete} 2>/dev/null || warn "Could not create Downloads directory structure"
        else
            log "Found existing Downloads directory"
            # Ensure subdirectories exist
            mkdir -p "$downloads_dir"/{complete,incomplete} 2>/dev/null || warn "Could not create Downloads subdirectories"
        fi
        
        MEDIA_BASE_DIR="$MOUNT_POINT/MULTIMEDIA"
        MOVIES_PATH="$filmes_dir"
        DOWNLOADS_PATH="$downloads_dir"
        
    else
        warn "MULTIMEDIA directory not found, creating new structure..."
        mkdir -p $MOUNT_POINT/MULTIMEDIA/{Filmes,Downloads/{complete,incomplete}} 2>/dev/null || {
            error "Could not create MULTIMEDIA directory structure"
            return 1
        }
        MEDIA_BASE_DIR="$MOUNT_POINT/MULTIMEDIA"
        MOVIES_PATH="$MOUNT_POINT/MULTIMEDIA/Filmes"
        DOWNLOADS_PATH="$MOUNT_POINT/MULTIMEDIA/Downloads"
    fi
    
    # Set ownership (for Docker containers) - only if we can write
    if [[ -w "$MEDIA_BASE_DIR" ]]; then
        chown -R $DOCKER_USER_ID:$DOCKER_USER_ID "$DOWNLOADS_PATH" 2>/dev/null || warn "Could not change ownership of Downloads directory"
        chmod -R 755 "$DOWNLOADS_PATH" 2>/dev/null || warn "Could not change permissions on Downloads directory"
        log "Permissions set for Downloads directory (owner: $DOCKER_USER_ID)"
    else
        warn "Media directory is not writable - you may need to fix permissions manually"
    fi
    
    log "Media directory structure configured:"
    log "  Movies (Filmes): $MOVIES_PATH"
    log "  Downloads: $DOWNLOADS_PATH"
    
    # Show mount status
    echo -e "${BLUE}Mount Status:${NC}"
    df -h | grep $MOUNT_POINT || df -h | grep "$(basename $main_partition)"
    
    log "Disk setup completed successfully"
    
    # Store the partition for cleanup reference
    ISCSI_PARTITION="$main_partition"
}

# Configure LXC bind mount and UID/GID mapping
setup_lxc_bind_mount() {
    log "Setting up LXC bind mount and UID/GID mapping..."
    
    local lxc_config="/etc/pve/lxc/${LXC_CONTAINER_ID}.conf"
    
    if [[ ! -f "$lxc_config" ]]; then
        error "LXC config file not found: $lxc_config"
        return 1
    fi
    
    # Backup LXC config
    cp "$lxc_config" "${lxc_config}.backup-$(date +%Y%m%d-%H%M%S)"
    
    # Configure subuid and subgid for proper UID mapping
    log "Configuring UID/GID mapping for unprivileged LXC container..."
    
    # Backup original files
    cp /etc/subuid /etc/subuid.backup-$(date +%Y%m%d-%H%M%S)
    cp /etc/subgid /etc/subgid.backup-$(date +%Y%m%d-%H%M%S)
    
    # Remove existing conflicting entries
    sed -i "/root:$DOCKER_USER_ID:1/d" /etc/subuid
    sed -i "/root:$DOCKER_USER_ID:1/d" /etc/subgid
    
    # Modify the subuid/subgid files to split the range
    sed -i "s/root:100000:65536/root:100000:$DOCKER_USER_ID/" /etc/subuid
    sed -i "s/root:100000:65536/root:100000:$DOCKER_USER_ID/" /etc/subgid
    
    # Add the specific mapping for the Docker user ID
    echo "root:$DOCKER_USER_ID:1" >> /etc/subuid
    echo "root:$DOCKER_USER_ID:1" >> /etc/subgid
    
    # Calculate remaining range
    local remaining_start=$((DOCKER_USER_ID + 1))
    local remaining_count=$((165535 - remaining_start))
    
    # Add the remaining range
    echo "root:1$remaining_start:$remaining_count" >> /etc/subuid
    echo "root:1$remaining_start:$remaining_count" >> /etc/subgid
    
    log "Updated /etc/subuid and /etc/subgid for UID $DOCKER_USER_ID mapping"
    
    # Check if bind mount already exists
    if grep -q "mp.*nas-library" "$lxc_config"; then
        warn "Bind mount already exists in LXC config"
    else
        # Add bind mount to LXC config
        echo "mp0: $MOUNT_POINT,mp=/mnt/nas-library" >> "$lxc_config"
        log "Added bind mount to LXC config"
    fi
    
    # Check if idmap already configured
    if grep -q "lxc.idmap.*$DOCKER_USER_ID.*$DOCKER_USER_ID" "$lxc_config"; then
        warn "UID mapping already configured in LXC config"
    else
        # Add UID/GID mapping to LXC config
        local remaining_start=$((DOCKER_USER_ID + 1))
        local remaining_count=$((165535 - remaining_start))
        
        cat >> "$lxc_config" << EOF

# UID/GID mapping for Docker user ($DOCKER_USER_ID)
lxc.idmap: u 0 100000 $DOCKER_USER_ID
lxc.idmap: u $DOCKER_USER_ID $DOCKER_USER_ID 1
lxc.idmap: u $remaining_start 1$remaining_start $remaining_count
lxc.idmap: g 0 100000 $DOCKER_USER_ID
lxc.idmap: g $DOCKER_USER_ID $DOCKER_USER_ID 1
lxc.idmap: g $remaining_start 1$remaining_start $remaining_count
EOF
        log "Added UID/GID mapping for user $DOCKER_USER_ID to LXC config"
    fi
    
    # Set proper ownership on the mount point for the Docker user
    log "Setting ownership on media directories..."
    chown -R $DOCKER_USER_ID:$DOCKER_USER_ID /mnt/nas-library/MULTIMEDIA/ 2>/dev/null || warn "Could not change all ownership (some files may be read-only)"
    
    # Ask about container restart
    warn "LXC container needs to be restarted to apply bind mount and UID mapping"
    read -p "Restart container $LXC_CONTAINER_ID now? (Y/n): " restart_choice
    
    if [[ "$restart_choice" =~ ^[Nn]$ ]]; then
        restart_choice="y"  # Default to yes
    fi
    
    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        log "Restarting LXC container..."
        pct stop $LXC_CONTAINER_ID
        sleep 5
        
        # Start container and check for errors
        if pct start $LXC_CONTAINER_ID; then
            sleep 10
            log "Container restarted successfully"
            
            # Test bind mount
            if pct exec $LXC_CONTAINER_ID -- ls -la /mnt/nas-library/MULTIMEDIA/ &>/dev/null; then
                log "✓ Bind mount is working in container"
                
                # Test write permissions
                if pct exec $LXC_CONTAINER_ID -- touch /mnt/nas-library/MULTIMEDIA/test-permissions 2>/dev/null; then
                    log "✓ Write permissions working in container"
                    pct exec $LXC_CONTAINER_ID -- rm /mnt/nas-library/MULTIMEDIA/test-permissions
                else
                    warn "Write permissions may need adjustment in container"
                fi
            else
                warn "Bind mount may not be working - check manually"
            fi
        else
            error "Failed to start container. Check configuration:"
            echo "pct config $LXC_CONTAINER_ID"
            return 1
        fi
    else
        warn "Remember to restart container: pct restart $LXC_CONTAINER_ID"
    fi
}

# Test the complete setup
test_setup() {
    log "Testing the complete setup..."
    
    # Test Proxmox host mount
    if mount | grep -q $MOUNT_POINT; then
        log "✓ iSCSI disk mounted on Proxmox host"
        
        # Show mount details
        local mount_info
        mount_info=$(mount | grep $MOUNT_POINT)
        log "Mount details: $mount_info"
    else
        error "✗ iSCSI disk not mounted"
        return 1
    fi
    
    # Test iSCSI session
    if iscsiadm -m session | grep -q "$ISCSI_TARGET"; then
        log "✓ iSCSI session active"
    else
        warn "iSCSI session may not be active"
        iscsiadm -m session
    fi
    
    # Test write permissions on host
    if [[ -n "$DOWNLOADS_PATH" ]] && touch "$DOWNLOADS_PATH"/test-write 2>/dev/null; then
        log "✓ Write permissions working on Downloads directory"
        rm "$DOWNLOADS_PATH"/test-write
    elif touch $MOUNT_POINT/MULTIMEDIA/test-write 2>/dev/null; then
        log "✓ Write permissions working on MULTIMEDIA directory"
        rm $MOUNT_POINT/MULTIMEDIA/test-write
    else
        error "✗ Write permission test failed"
        ls -la $MOUNT_POINT/MULTIMEDIA/ 2>/dev/null || ls -la $MOUNT_POINT/
        return 1
    fi
    
    # Test directory structure
    if [[ -d "${MOVIES_PATH:-$MOUNT_POINT/MULTIMEDIA/Filmes}" && -d "${DOWNLOADS_PATH:-$MOUNT_POINT/MULTIMEDIA/Downloads}" ]]; then
        log "✓ Directory structure verified"
        log "  Movies (Filmes): ${MOVIES_PATH:-$MOUNT_POINT/MULTIMEDIA/Filmes}"
        log "  Downloads: ${DOWNLOADS_PATH:-$MOUNT_POINT/MULTIMEDIA/Downloads}"
    else
        error "✗ Directory structure missing"
        return 1
    fi
    
    # Show disk usage
    echo -e "${BLUE}Disk Usage:${NC}"
    df -h | grep -E "(Filesystem|$MOUNT_POINT)" || df -h | grep -E "(Filesystem|nas-library)"
    
    log "Setup tests completed successfully"
}

# Display final summary
show_summary() {
    echo
    echo -e "${GREEN}=== Proxmox Host iSCSI + NFS Setup Complete ===${NC}"
    echo "NAS IP: $NAS_IP"
    echo "iSCSI Target: $ISCSI_TARGET"
    echo "Proxmox Mount: $MOUNT_POINT"
    echo "Media Base Directory: ${MEDIA_BASE_DIR:-$MOUNT_POINT/MULTIMEDIA}"
    echo "LXC Container: $LXC_CONTAINER_ID"
    echo "LXC Mount Path: $MOUNT_POINT"
    echo "Docker User ID: $DOCKER_USER_ID"
    echo "Kodi IP: $KODI_IP"
    echo
    echo -e "${BLUE}Docker Volume Paths (for LXC container):${NC}"
    echo "Movies (Filmes): $MOUNT_POINT/MULTIMEDIA/Filmes"
    echo "Downloads: $MOUNT_POINT/MULTIMEDIA/Downloads"
    echo
    echo -e "${BLUE}NFS Shares for Kodi ($(hostname -I | awk '{print $1}')):${NC}"
    for folder in $NFS_FOLDERS; do
        echo "$folder: nfs://$(hostname -I | awk '{print $1}')$MOUNT_POINT/MULTIMEDIA/$folder"
    done
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Verify bind mount in container: pct exec $LXC_CONTAINER_ID -- ls -la $MOUNT_POINT/"
    echo "2. Update Docker Compose with the paths above"
    echo "3. Deploy your media stack in Portainer"
    echo "4. Configure Kodi with the NFS paths listed above"
    echo "5. Test NFS access from Kodi: showmount -e $(hostname -I | awk '{print $1}')"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "Check iSCSI: iscsiadm -m session"
    echo "Check mount: df -h | grep $(basename $MOUNT_POINT)"  
    echo "Check NFS exports: showmount -e localhost"
    echo "Restart container: pct restart $LXC_CONTAINER_ID"
    echo "Restart NFS: systemctl restart nfs-kernel-server"
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
    discover_and_connect
    setup_disk_and_mount
    install_configure_nfs
    setup_lxc_bind_mount
    test_setup
    show_summary
    
    log "Proxmox host iSCSI + NFS setup completed successfully!"
}

main "$@"
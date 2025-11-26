#!/bin/bash

# Proxmox Host NFS + LXC Setup Script
# Script #2: Sets up NFS server for Kodi media streaming and configures LXC bind mounts

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
MOUNT_POINT="/mnt/nas-home"
LXC_CONTAINER_ID=""
DOCKER_USER_ID=""
KODI_IP=""
NFS_FOLDERS=""

# Show script description
show_script_description() {
    echo -e "${GREEN}=== Proxmox Host NFS + LXC Setup Script ===${NC}"
    echo
    echo "This script will configure NFS server and LXC bind mounts:"
    echo
    echo -e "${BLUE}Features:${NC}"
    echo "• Install and configure NFS server"
    echo "• Create NFS exports for media folders (accessible by Kodi)"
    echo "• Configure LXC bind mounts with proper UID/GID mapping"
    echo "• Set up permissions for Docker containers in LXC"
    echo "• Enable Docker containers to read/write to NAS storage"
    echo
    echo -e "${YELLOW}Prerequisites:${NC}"
    echo "• Proxmox VE host with mounted NAS storage"
    echo "• LXC container running Docker/Portainer"
    echo "• Kodi device on the same network for NFS access"
    echo "• iSCSI storage already mounted (run proxmox-iscsi-samba.sh first)"
    echo
    read -p "Continue with setup? (Y/n): " continue_setup
    if [[ "$continue_setup" =~ ^[Nn]$ ]]; then
        echo "Setup cancelled by user"
        exit 0
    fi
    echo
}

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

# Function to get Docker user selection
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

# Collect configuration
collect_config() {
    echo -e "${BLUE}=== Configuration Setup ===${NC}"
    echo "Please provide all configuration details:"
    echo
    
    read -p "Enter mount point path [/mnt/nas-home]: " MOUNT_POINT
    read -p "Enter LXC Container ID (where Docker runs) [23001]: " LXC_CONTAINER_ID
    read -p "Enter Kodi/NFS client IP address [192.168.8.15]: " KODI_IP
    
    # Use defaults if empty
    if [[ -z "$MOUNT_POINT" ]]; then
        MOUNT_POINT="/mnt/nas-home"
    fi
    
    if [[ -z "$LXC_CONTAINER_ID" ]]; then
        LXC_CONTAINER_ID="23001"
    fi
    
    if [[ -z "$KODI_IP" ]]; then
        KODI_IP="192.168.8.15"
    fi
    
    # Validate mount point exists
    if [[ ! -d "$MOUNT_POINT" ]]; then
        error "Mount point $MOUNT_POINT does not exist"
        echo "Please run proxmox-iscsi-samba.sh first to set up iSCSI storage"
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
    
    # Create MULTIMEDIA directory structure if it doesn't exist
    if [[ ! -d "$MOUNT_POINT/MULTIMEDIA" ]]; then
        log "Creating MULTIMEDIA directory structure..."
        mkdir -p "$MOUNT_POINT/MULTIMEDIA"
        chown "$DOCKER_USER_ID:$DOCKER_USER_ID" "$MOUNT_POINT/MULTIMEDIA"
    fi
    
    # Create exports for selected folders
    for folder in $NFS_FOLDERS; do
        local folder_path="$MOUNT_POINT/MULTIMEDIA/$folder"
        local export_line="$folder_path $KODI_IP(rw,sync,no_subtree_check,nohide,all_squash,anonuid=$DOCKER_USER_ID,anongid=$DOCKER_USER_ID,insecure)"
        
        # Create folder if it doesn't exist
        if [[ ! -d "$folder_path" ]]; then
            log "Creating NFS export folder: $folder_path"
            mkdir -p "$folder_path"
            chown "$DOCKER_USER_ID:$DOCKER_USER_ID" "$folder_path"
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
        ufw allow from "$KODI_IP" to any port nfs
        ufw allow from "$KODI_IP" to any port 111
        ufw allow from "$KODI_IP" to any port 2049
    fi
    
    log "NFS server configuration completed"
    
    echo -e "${BLUE}Kodi NFS mount information:${NC}"
    echo "Server IP: $(hostname -I | awk '{print $1}')"
    echo "NFS Paths for Kodi:"
    for folder in $NFS_FOLDERS; do
        echo "  $folder: nfs://$(hostname -I | awk '{print $1}')$MOUNT_POINT/MULTIMEDIA/$folder"
    done
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
    chown -R "$DOCKER_USER_ID:$DOCKER_USER_ID" "$MOUNT_POINT/MULTIMEDIA/" 2>/dev/null || warn "Could not change all ownership (some files may be read-only)"
    
    # Ask about container restart
    warn "LXC container needs to be restarted to apply bind mount and UID mapping"
    read -p "Restart container $LXC_CONTAINER_ID now? (Y/n): " restart_choice
    
    if [[ "$restart_choice" =~ ^[Nn]$ ]]; then
        restart_choice="y"  # Default to yes
    fi
    
    if [[ "$restart_choice" =~ ^[Yy]$ ]]; then
        log "Restarting LXC container..."
        pct stop "$LXC_CONTAINER_ID"
        sleep 5
        
        # Start container and check for errors
        if pct start "$LXC_CONTAINER_ID"; then
            sleep 10
            log "Container restarted successfully"
            
            # Test bind mount
            if pct exec "$LXC_CONTAINER_ID" -- ls -la /mnt/nas-library/MULTIMEDIA/ &>/dev/null; then
                log "✓ Bind mount is working in container"
                
                # Test write permissions
                if pct exec "$LXC_CONTAINER_ID" -- touch /mnt/nas-library/MULTIMEDIA/test-permissions 2>/dev/null; then
                    log "✓ Write permissions working in container"
                    pct exec "$LXC_CONTAINER_ID" -- rm /mnt/nas-library/MULTIMEDIA/test-permissions
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
    
    # Test mount point
    if [[ -d "$MOUNT_POINT/MULTIMEDIA" ]]; then
        log "✓ MULTIMEDIA directory exists"
        
        # Show directory structure
        echo -e "${BLUE}MULTIMEDIA Directory Structure:${NC}"
        ls -la "$MOUNT_POINT/MULTIMEDIA/" 2>/dev/null || echo "Could not list MULTIMEDIA contents"
    else
        error "✗ MULTIMEDIA directory missing"
        return 1
    fi
    
    # Test NFS exports
    echo -e "${BLUE}NFS Export Status:${NC}"
    exportfs -v | grep -E "(Filmes|Musica|Series|Documentarios)" || warn "No NFS exports found"
    
    # Test NFS service
    if systemctl is-active --quiet nfs-kernel-server; then
        log "✓ NFS server is running"
    else
        error "✗ NFS server is not running"
        return 1
    fi
    
    # Test LXC container access (if container is running)
    if pct status "$LXC_CONTAINER_ID" | grep -q "running"; then
        if pct exec "$LXC_CONTAINER_ID" -- ls /mnt/nas-library/MULTIMEDIA/ &>/dev/null; then
            log "✓ LXC container can access bind mount"
        else
            warn "LXC container cannot access bind mount"
        fi
    else
        warn "LXC container is not running - cannot test bind mount"
    fi
    
    log "Setup tests completed"
}

# Display final summary
show_summary() {
    echo
    echo -e "${GREEN}=== Proxmox Host NFS + LXC Setup Complete ===${NC}"
    echo "Mount Point: $MOUNT_POINT"
    echo "LXC Container: $LXC_CONTAINER_ID"
    echo "Docker User ID: $DOCKER_USER_ID"
    echo "Kodi IP: $KODI_IP"
    echo
    echo -e "${BLUE}Docker Volume Paths (for LXC container):${NC}"
    echo "Movies (Filmes): /mnt/nas-library/MULTIMEDIA/Filmes"
    echo "Downloads: /mnt/nas-library/MULTIMEDIA/Downloads"
    echo
    echo -e "${BLUE}NFS Shares for Kodi ($(hostname -I | awk '{print $1}')):${NC}"
    for folder in $NFS_FOLDERS; do
        echo "$folder: nfs://$(hostname -I | awk '{print $1}')$MOUNT_POINT/MULTIMEDIA/$folder"
    done
    echo
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Verify bind mount in container: pct exec $LXC_CONTAINER_ID -- ls -la /mnt/nas-library/"
    echo "2. Update Docker Compose with the paths above"
    echo "3. Deploy your media stack in Portainer"
    echo "4. Configure Kodi with the NFS paths listed above"
    echo "5. Test NFS access from Kodi: showmount -e $(hostname -I | awk '{print $1}')"
    echo
    echo -e "${BLUE}Management Commands:${NC}"
    echo "Check NFS exports: showmount -e localhost"
    echo "Check NFS service: systemctl status nfs-kernel-server"
    echo "Restart container: pct restart $LXC_CONTAINER_ID"
    echo "Check bind mount: pct exec $LXC_CONTAINER_ID -- df -h | grep nas-library"
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
    install_configure_nfs
    setup_lxc_bind_mount
    test_setup
    show_summary
    
    log "Proxmox host NFS + LXC setup completed successfully!"
}

# Run main function
main "$@"

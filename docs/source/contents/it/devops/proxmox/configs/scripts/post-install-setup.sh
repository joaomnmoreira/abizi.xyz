#!/bin/bash

# Proxmox Post-Install Setup Script
# This script automates the post-installation configuration of Proxmox VE
# Run as root on fresh Proxmox installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

log "Starting Proxmox Post-Install Configuration"

# 1. Remove local-lvm and extend root partition
log "Removing local-lvm storage and extending root partition..."
if lvs | grep -q "data"; then
    lvremove -y /dev/pve/data
    lvresize -l +100%FREE /dev/pve/root
    resize2fs /dev/mapper/pve-root
    log "Storage reconfiguration completed"
else
    warn "local-lvm not found, skipping storage reconfiguration"
fi

# 2. Configure repositories
log "Configuring package repositories..."

# Disable enterprise repositories
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
    log "Disabled PVE Enterprise repository"
fi

if [ -f /etc/apt/sources.list.d/ceph.list ]; then
    sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list
    log "Disabled Ceph Enterprise repository"
fi

# Add no-subscription repository
if ! grep -q "pve-no-subscription" /etc/apt/sources.list; then
    echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" >> /etc/apt/sources.list
    log "Added PVE No-Subscription repository"
fi

# 3. Update system
log "Updating package lists and upgrading system..."
apt update
apt upgrade -y

# 4. Install useful packages
log "Installing additional useful packages..."
apt install -y \
    curl \
    wget \
    vim \
    htop \
    iotop \
    iftop \
    ncdu \
    tree \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# 5. Disable enterprise popup
log "Disabling enterprise subscription popup..."
PROXMOX_LIB="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
if [ -f "$PROXMOX_LIB" ]; then
    cp "$PROXMOX_LIB" "${PROXMOX_LIB}.bak"
    sed -i "s/data.status !== 'Active'/false/g" "$PROXMOX_LIB"
    systemctl restart pveproxy.service
    log "Enterprise popup disabled"
else
    warn "Proxmox library file not found, skipping popup disable"
fi

# 6. Configure automatic updates (optional)
log "Configuring automatic security updates..."
cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# 7. Create directory structure for services
log "Creating directory structure for Docker services..."
mkdir -p /docker/{transmission/{data,watch},prowlarr/config,radarr/config,bazarr/config}
mkdir -p /opt/docker/media-stack
mkdir -p /mnt/nas-library/MULTIMEDIA/{movies,Downloads/{complete,incomplete}}

# Create arr-stack user
if ! id "arr-stack" &>/dev/null; then
    adduser arr-stack --uid 1002 --disabled-password --gecos ""
    log "Created arr-stack user (UID: 1002)"
fi

# Set permissions
chown -R 1002:1002 /docker/
log "Set permissions for Docker directories"

# 8. Configure network (example - adjust as needed)
log "Network configuration template created at /tmp/interfaces.example"
cat > /tmp/interfaces.example << EOF
# Example network configuration
# Copy to /etc/network/interfaces and modify as needed

auto lo
iface lo inet loopback

# Management interface
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.240/24
    gateway 192.168.1.1
    bridge-ports enp0s31f6
    bridge-stp off
    bridge-fd 0

# Optional: Additional bridge for VMs
#auto vmbr1
#iface vmbr1 inet manual
#    bridge-ports enp0s31f7
#    bridge-stp off
#    bridge-fd 0
EOF

# 9. Create backup script
log "Creating backup script..."
cat > /usr/local/bin/proxmox-backup.sh << 'EOF'
#!/bin/bash
# Simple Proxmox backup script
# Customize as needed for your environment

BACKUP_DIR="/mnt/backup"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup Proxmox configuration
tar -czf "$BACKUP_DIR/pve-config-$DATE.tar.gz" /etc/pve/

# Backup Docker configurations
if [ -d "/docker" ]; then
    tar -czf "$BACKUP_DIR/docker-configs-$DATE.tar.gz" /docker/
fi

# Clean old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /usr/local/bin/proxmox-backup.sh
log "Backup script created at /usr/local/bin/proxmox-backup.sh"

# 10. Final steps
log "Post-install configuration completed successfully!"
log ""
log "Next steps:"
log "1. Reboot the system: 'reboot'"
log "2. Configure network settings if needed: /etc/network/interfaces"
log "3. Set up storage: Run storage-setup.sh"
log "4. Deploy services: Use docker-compose files in configs/"
log "5. Configure monitoring and backups"
log ""
log "Web interface: https://$(hostname -I | awk '{print $1}'):8006"

# Ask for reboot
read -p "Reboot now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    reboot
fi

==================
Update Procedures
==================

.. highlight:: console

System update procedures for Proxmox VE, containers, and services.

📋 Update Strategy Overview
==========================

Systematic approach to updates:

- **Proxmox Host Updates**: Core system and kernel updates
- **VM/Container Updates**: Guest operating system updates
- **Service Updates**: Docker containers and applications
- **Security Updates**: Critical security patches
- **Rollback Procedures**: Recovery from failed updates

🔧 Proxmox Host Updates
=======================

Pre-Update Preparation
---------------------

.. code-block:: bash

   # Create system backup before updates
   /usr/local/bin/config-backup.sh
   
   # Check current system status
   pveversion
   df -h
   free -h
   
   # Verify all VMs and containers are running properly
   qm list
   pct list
   
   # Check for any running backup jobs
   ps aux | grep vzdump

Repository Configuration
-----------------------

.. code-block:: bash

   # Verify repository configuration
   cat /etc/apt/sources.list
   cat /etc/apt/sources.list.d/pve-*.list
   
   # Update package lists
   apt update

Standard Update Process
----------------------

.. code-block:: bash

   # Check available updates
   apt list --upgradable
   
   # Perform system update
   apt update && apt upgrade -y
   
   # Update Proxmox packages specifically
   apt dist-upgrade -y
   
   # Clean package cache
   apt autoremove -y
   apt autoclean

Kernel Updates
-------------

.. code-block:: bash

   # Check current kernel
   uname -r
   
   # List available kernels
   apt list pve-kernel-*
   
   # Install specific kernel version if needed
   apt install pve-kernel-5.15.74-1-pve
   
   # Update GRUB configuration
   update-grub
   
   # Reboot to apply kernel updates
   reboot

Post-Update Verification
-----------------------

.. code-block:: bash

   # Verify system status after reboot
   pveversion
   systemctl status pveproxy pvedaemon pve-cluster
   
   # Check all VMs and containers
   qm list
   pct list
   
   # Verify network connectivity
   ping -c 3 8.8.8.8
   
   # Check storage status
   zpool status
   df -h

🖥️ VM and Container Updates
===========================

Linux VM Updates
----------------

**Ubuntu/Debian VMs**:

.. code-block:: bash

   # Connect to VM
   qm guest exec 100 -- bash
   
   # Or SSH to VM
   ssh user@vm-ip
   
   # Update system
   sudo apt update && sudo apt upgrade -y
   sudo apt autoremove -y
   
   # Reboot if kernel updated
   sudo reboot

**CentOS/RHEL VMs**:

.. code-block:: bash

   # Update system
   sudo yum update -y
   # or for newer versions
   sudo dnf update -y
   
   # Reboot if needed
   sudo reboot

**Automated VM Updates**:

.. code-block:: bash

   cat > /usr/local/bin/update-vms.sh << 'EOF'
   #!/bin/bash
   
   # VM Update Script
   
   VMS=(100 101 102)  # List of VM IDs to update
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   for vm in "${VMS[@]}"; do
       log "Updating VM $vm..."
       
       # Check if VM is running
       if qm status $vm | grep -q "status: running"; then
           # Execute update commands in VM
           qm guest exec $vm -- apt update
           qm guest exec $vm -- apt upgrade -y
           qm guest exec $vm -- apt autoremove -y
           
           log "VM $vm updated successfully"
       else
           log "VM $vm is not running, skipping..."
       fi
   done
   EOF
   
   chmod +x /usr/local/bin/update-vms.sh

LXC Container Updates
--------------------

.. code-block:: bash

   # Update specific container
   pct exec 200 -- apt update
   pct exec 200 -- apt upgrade -y
   pct exec 200 -- apt autoremove -y
   
   # Restart container if needed
   pct reboot 200

**Automated Container Updates**:

.. code-block:: bash

   cat > /usr/local/bin/update-containers.sh << 'EOF'
   #!/bin/bash
   
   # Container Update Script
   
   CONTAINERS=(200 201 202)  # List of container IDs
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   for ct in "${CONTAINERS[@]}"; do
       log "Updating container $ct..."
       
       if pct status $ct | grep -q "status: running"; then
           pct exec $ct -- apt update
           pct exec $ct -- apt upgrade -y
           pct exec $ct -- apt autoremove -y
           
           log "Container $ct updated successfully"
       else
           log "Container $ct is not running, skipping..."
       fi
   done
   EOF
   
   chmod +x /usr/local/bin/update-containers.sh

🐳 Docker Service Updates
========================

Docker Container Updates
------------------------

.. code-block:: bash

   # Navigate to docker-compose directory
   cd /opt/docker/media-stack
   
   # Pull latest images
   docker-compose pull
   
   # Recreate containers with new images
   docker-compose up -d
   
   # Remove old images
   docker image prune -f

**Automated Docker Updates**:

.. code-block:: bash

   cat > /usr/local/bin/update-docker-services.sh << 'EOF'
   #!/bin/bash
   
   # Docker Services Update Script
   
   COMPOSE_DIRS=(
       "/opt/docker/media-stack"
       "/opt/docker/monitoring"
   )
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   for dir in "${COMPOSE_DIRS[@]}"; do
       if [ -d "$dir" ] && [ -f "$dir/docker-compose.yml" ]; then
           log "Updating services in $dir..."
           
           cd "$dir"
           
           # Create backup of current state
           docker-compose config > "docker-compose.backup.$(date +%Y%m%d_%H%M%S).yml"
           
           # Pull latest images
           docker-compose pull
           
           # Recreate services
           docker-compose up -d
           
           # Clean up old images
           docker image prune -f
           
           log "Services in $dir updated successfully"
       else
           log "Directory $dir not found or no docker-compose.yml, skipping..."
       fi
   done
   
   # Clean up unused volumes and networks
   docker volume prune -f
   docker network prune -f
   
   log "Docker services update completed"
   EOF
   
   chmod +x /usr/local/bin/update-docker-services.sh

Docker Engine Updates
--------------------

.. code-block:: bash

   # Update Docker engine in LXC container
   pct exec 300 -- apt update
   pct exec 300 -- apt upgrade docker-ce docker-ce-cli containerd.io
   
   # Restart Docker service
   pct exec 300 -- systemctl restart docker
   
   # Verify Docker is working
   pct exec 300 -- docker version

🔒 Security Updates
==================

Critical Security Patches
-------------------------

.. code-block:: bash

   # Check for security updates
   apt list --upgradable | grep -i security
   
   # Install only security updates
   unattended-upgrade -d
   
   # Or manually install specific security updates
   apt install package-name

**Automated Security Updates**:

.. code-block:: bash

   # Configure automatic security updates
   cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
   Unattended-Upgrade::Allowed-Origins {
       "${distro_id}:${distro_codename}-security";
       "Proxmox:${distro_codename}";
   };
   
   Unattended-Upgrade::AutoFixInterruptedDpkg "true";
   Unattended-Upgrade::MinimalSteps "true";
   Unattended-Upgrade::Remove-Unused-Dependencies "true";
   Unattended-Upgrade::Automatic-Reboot "false";
   EOF
   
   # Enable automatic updates
   cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
   APT::Periodic::Update-Package-Lists "1";
   APT::Periodic::Unattended-Upgrade "1";
   APT::Periodic::AutocleanInterval "7";
   EOF

Vulnerability Scanning
---------------------

.. code-block:: bash

   # Install vulnerability scanner
   apt install lynis
   
   # Run security audit
   lynis audit system
   
   # Check for known vulnerabilities
   apt install debsecan
   debsecan --suite $(lsb_release -cs) --format packages

⏰ Update Scheduling
===================

Maintenance Windows
------------------

**Scheduled Maintenance Script**:

.. code-block:: bash

   cat > /usr/local/bin/maintenance-window.sh << 'EOF'
   #!/bin/bash
   
   # Maintenance Window Script
   # Run during scheduled maintenance periods
   
   MAINTENANCE_LOG="/var/log/maintenance.log"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MAINTENANCE_LOG"
   }
   
   log "=== Starting Maintenance Window ==="
   
   # 1. Backup configurations
   log "Creating configuration backup..."
   /usr/local/bin/config-backup.sh
   
   # 2. Update Proxmox host
   log "Updating Proxmox host..."
   apt update && apt upgrade -y
   
   # 3. Update containers
   log "Updating containers..."
   /usr/local/bin/update-containers.sh
   
   # 4. Update Docker services
   log "Updating Docker services..."
   /usr/local/bin/update-docker-services.sh
   
   # 5. System cleanup
   log "Performing system cleanup..."
   apt autoremove -y
   apt autoclean
   docker system prune -f
   
   # 6. Verify services
   log "Verifying services..."
   systemctl status pveproxy pvedaemon pve-cluster
   
   log "=== Maintenance Window Completed ==="
   EOF
   
   chmod +x /usr/local/bin/maintenance-window.sh

Cron Scheduling
--------------

.. code-block:: bash

   # Edit root crontab
   crontab -e
   
   # Schedule updates
   # Security updates daily at 3 AM
   0 3 * * * unattended-upgrade
   
   # Full maintenance window monthly (first Sunday at 2 AM)
   0 2 1-7 * 0 /usr/local/bin/maintenance-window.sh
   
   # Docker updates weekly (Sunday at 4 AM)
   0 4 * * 0 /usr/local/bin/update-docker-services.sh

🔄 Rollback Procedures
=====================

System Rollback
---------------

**Kernel Rollback**:

.. code-block:: bash

   # List available kernels
   dpkg --list | grep pve-kernel
   
   # Set default kernel in GRUB
   nano /etc/default/grub
   # Set: GRUB_DEFAULT="1>2"  # Boot second kernel in submenu
   
   # Update GRUB and reboot
   update-grub
   reboot

**Package Rollback**:

.. code-block:: bash

   # Hold package at current version
   apt-mark hold package-name
   
   # Downgrade to specific version
   apt install package-name=version
   
   # Remove hold when ready
   apt-mark unhold package-name

VM/Container Rollback
--------------------

.. code-block:: bash

   # Restore VM from backup
   qmrestore /backup/vzdump-qemu-100-date.vma.zst 100
   
   # Restore container from backup
   pct restore 200 /backup/vzdump-lxc-200-date.tar.zst

Docker Service Rollback
-----------------------

.. code-block:: bash

   # Rollback to previous image version
   cd /opt/docker/media-stack
   
   # Use backup compose file
   cp docker-compose.backup.20241201_020000.yml docker-compose.yml
   
   # Recreate services
   docker-compose up -d

📊 Update Monitoring
===================

Update Status Tracking
----------------------

.. code-block:: bash

   cat > /usr/local/bin/update-status.sh << 'EOF'
   #!/bin/bash
   
   # Update Status Report
   
   echo "=== Proxmox Update Status Report ==="
   echo "Generated: $(date)"
   echo
   
   echo "=== System Information ==="
   pveversion
   uname -r
   echo
   
   echo "=== Available Updates ==="
   apt list --upgradable 2>/dev/null | grep -v "WARNING"
   echo
   
   echo "=== Security Updates ==="
   apt list --upgradable 2>/dev/null | grep -i security
   echo
   
   echo "=== Last Update ==="
   grep "upgrade" /var/log/apt/history.log | tail -5
   echo
   
   echo "=== System Uptime ==="
   uptime
   echo
   
   echo "=== Service Status ==="
   systemctl status pveproxy pvedaemon pve-cluster --no-pager -l
   EOF
   
   chmod +x /usr/local/bin/update-status.sh

Update Notifications
-------------------

.. code-block:: bash

   cat > /usr/local/bin/update-notify.sh << 'EOF'
   #!/bin/bash
   
   # Update Notification Script
   
   ALERT_EMAIL="admin@yourdomain.com"
   
   # Check for available updates
   updates=$(apt list --upgradable 2>/dev/null | grep -v "WARNING" | wc -l)
   security_updates=$(apt list --upgradable 2>/dev/null | grep -i security | wc -l)
   
   if [ $updates -gt 0 ]; then
       subject="Proxmox Updates Available: $updates total, $security_updates security"
       message="Updates available on $(hostname):
   
   Total updates: $updates
   Security updates: $security_updates
   
   Available updates:
   $(apt list --upgradable 2>/dev/null | grep -v "WARNING")
   
   Please schedule maintenance to apply updates."
   
       echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
   fi
   EOF
   
   chmod +x /usr/local/bin/update-notify.sh

📋 Update Checklist
===================

Pre-Update Checklist:

- [ ] **Configuration backup** created
- [ ] **VM/container status** verified
- [ ] **No running backup jobs**
- [ ] **Maintenance window** scheduled
- [ ] **Rollback plan** prepared
- [ ] **Stakeholders notified**

During Update:

- [ ] **System updates** applied
- [ ] **VM/container updates** completed
- [ ] **Docker services** updated
- [ ] **Security patches** installed
- [ ] **System rebooted** if required
- [ ] **Services verified** operational

Post-Update Checklist:

- [ ] **System status** verified
- [ ] **All services** running properly
- [ ] **Network connectivity** confirmed
- [ ] **Storage systems** healthy
- [ ] **Monitoring** operational
- [ ] **Update log** documented

🚨 Troubleshooting
=================

Common Update Issues
-------------------

**Package Conflicts**:

.. code-block:: bash

   # Fix broken packages
   apt --fix-broken install
   
   # Reconfigure packages
   dpkg --configure -a
   
   # Force package installation
   apt install -f

**Repository Issues**:

.. code-block:: bash

   # Update GPG keys
   apt-key update
   
   # Fix repository sources
   nano /etc/apt/sources.list
   
   # Clear package cache
   apt clean && apt update

**Service Failures After Update**:

.. code-block:: bash

   # Check service status
   systemctl status service-name
   
   # Check logs
   journalctl -u service-name
   
   # Restart services
   systemctl restart pveproxy pvedaemon pve-cluster

**Boot Issues After Kernel Update**:

.. code-block:: bash

   # Boot from previous kernel (GRUB menu)
   # Remove problematic kernel
   apt remove pve-kernel-problematic-version
   
   # Reinstall working kernel
   apt install pve-kernel-working-version

📚 Additional Resources
======================

- `Proxmox VE Updates <https://pve.proxmox.com/wiki/Package_Repositories>`__
- `Debian Security Updates <https://www.debian.org/security/>`__
- `Docker Update Best Practices <https://docs.docker.com/config/containers/live-restore/>`__
- `System Maintenance Guide <https://pve.proxmox.com/pve-docs/pve-admin-guide.html>`__

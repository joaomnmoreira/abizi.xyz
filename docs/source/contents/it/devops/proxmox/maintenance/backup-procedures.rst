==================
Backup Procedures
==================

.. highlight:: console

Comprehensive backup and recovery procedures for Proxmox infrastructure and services.

📋 Backup Strategy Overview
===========================

Multi-layered backup approach:

- **Proxmox Configuration**: System settings and VM/CT definitions
- **VM/Container Backups**: Full system backups with scheduling
- **Application Data**: Service-specific data backups
- **Configuration Files**: Docker configs, scripts, and templates
- **Offsite Storage**: Remote backup destinations

🔧 Proxmox Built-in Backup
==========================

Automated VM/Container Backups
------------------------------

**Configure Backup Jobs**:

1. **Datacenter** → **Backup**
2. **Add** backup job with settings:
   - **Node**: Target Proxmox node
   - **Storage**: Backup destination storage
   - **Schedule**: Cron-style schedule (e.g., daily at 2 AM)
   - **Selection Mode**: Include/exclude VMs and containers
   - **Retention**: Number of backups to keep
   - **Compression**: gzip, lzo, or zstd
   - **Mode**: snapshot, suspend, or stop

**Example Backup Schedule**:

.. code-block:: text

   # Daily backups at 2 AM, keep 7 days
   Schedule: 0 2 * * *
   Retention: 7
   Compression: zstd
   Mode: snapshot

Manual Backup Commands
---------------------

.. code-block:: bash

   # Backup specific VM
   vzdump 100 --storage backup-storage --compress zstd --mode snapshot
   
   # Backup specific container
   vzdump 200 --storage backup-storage --compress gzip
   
   # Backup multiple VMs
   vzdump 100,101,102 --storage backup-storage
   
   # Backup all VMs and containers
   vzdump --all --storage backup-storage

📁 Configuration Backup Script
==============================

Automated configuration backup for critical files:

.. code-block:: bash

   cat > /usr/local/bin/config-backup.sh << 'EOF'
   #!/bin/bash
   
   # Configuration Backup Script
   # Backs up critical Proxmox and service configurations
   
   set -euo pipefail
   
   # Configuration
   BACKUP_DIR="/backup/configs"
   DATE=$(date +%Y%m%d_%H%M%S)
   RETENTION_DAYS=30
   
   # Create backup directory
   mkdir -p "$BACKUP_DIR"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   log "Starting configuration backup..."
   
   # Backup Proxmox configuration
   log "Backing up Proxmox configuration..."
   tar -czf "$BACKUP_DIR/pve-config-$DATE.tar.gz" \
       /etc/pve/ \
       /etc/network/interfaces \
       /etc/hosts \
       /etc/hostname \
       /etc/resolv.conf \
       2>/dev/null || true
   
   # Backup Docker configurations
   if [ -d "/docker" ]; then
       log "Backing up Docker configurations..."
       tar -czf "$BACKUP_DIR/docker-configs-$DATE.tar.gz" /docker/
   fi
   
   # Backup custom scripts
   if [ -d "/usr/local/bin" ]; then
       log "Backing up custom scripts..."
       tar -czf "$BACKUP_DIR/custom-scripts-$DATE.tar.gz" \
           /usr/local/bin/*.sh \
           2>/dev/null || true
   fi
   
   # Backup crontabs
   log "Backing up crontabs..."
   tar -czf "$BACKUP_DIR/crontabs-$DATE.tar.gz" \
       /var/spool/cron/crontabs/ \
       /etc/crontab \
       /etc/cron.d/ \
       2>/dev/null || true
   
   # Backup SSH configurations
   log "Backing up SSH configurations..."
   tar -czf "$BACKUP_DIR/ssh-configs-$DATE.tar.gz" \
       /etc/ssh/ \
       /root/.ssh/ \
       2>/dev/null || true
   
   # Clean old backups
   log "Cleaning old backups (older than $RETENTION_DAYS days)..."
   find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
   
   # Generate backup report
   log "Generating backup report..."
   cat > "$BACKUP_DIR/backup-report-$DATE.txt" << EOL
   Backup Report - $DATE
   =====================
   
   Backup Location: $BACKUP_DIR
   Retention: $RETENTION_DAYS days
   
   Files Created:
   $(ls -lh "$BACKUP_DIR"/*-$DATE.* 2>/dev/null || echo "No files created")
   
   Total Backup Size:
   $(du -sh "$BACKUP_DIR" 2>/dev/null || echo "Unable to calculate size")
   
   Available Space:
   $(df -h "$BACKUP_DIR" 2>/dev/null || echo "Unable to check space")
   EOL
   
   log "Configuration backup completed successfully!"
   log "Report saved to: $BACKUP_DIR/backup-report-$DATE.txt"
   EOF
   
   chmod +x /usr/local/bin/config-backup.sh

🗄️ Storage Backup Procedures
============================

ZFS Snapshot Management
----------------------

.. code-block:: bash

   # Create ZFS snapshot
   zfs snapshot ZFS01/Data01@backup-$(date +%Y%m%d_%H%M%S)
   
   # List snapshots
   zfs list -t snapshot
   
   # Send snapshot to remote location
   zfs send ZFS01/Data01@backup-20241201_020000 | ssh backup-server "zfs receive backup-pool/proxmox-data"
   
   # Automated snapshot script
   cat > /usr/local/bin/zfs-snapshot.sh << 'EOF'
   #!/bin/bash
   
   DATASET="ZFS01/Data01"
   SNAPSHOT_NAME="auto-$(date +%Y%m%d_%H%M%S)"
   RETENTION_DAYS=14
   
   # Create snapshot
   zfs snapshot "$DATASET@$SNAPSHOT_NAME"
   
   # Clean old snapshots
   zfs list -H -o name -t snapshot | grep "^$DATASET@auto-" | while read snap; do
       creation=$(zfs get -H -o value creation "$snap")
       if [[ $(date -d "$creation" +%s) -lt $(date -d "$RETENTION_DAYS days ago" +%s) ]]; then
           zfs destroy "$snap"
       fi
   done
   EOF
   
   chmod +x /usr/local/bin/zfs-snapshot.sh

Database Backup (if applicable)
------------------------------

.. code-block:: bash

   # PostgreSQL backup example
   cat > /usr/local/bin/db-backup.sh << 'EOF'
   #!/bin/bash
   
   BACKUP_DIR="/backup/databases"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   mkdir -p "$BACKUP_DIR"
   
   # Backup PostgreSQL databases
   docker exec postgres-container pg_dumpall -U postgres > "$BACKUP_DIR/postgres-$DATE.sql"
   
   # Compress backup
   gzip "$BACKUP_DIR/postgres-$DATE.sql"
   
   # Clean old backups (keep 7 days)
   find "$BACKUP_DIR" -name "postgres-*.sql.gz" -mtime +7 -delete
   EOF
   
   chmod +x /usr/local/bin/db-backup.sh

📤 Offsite Backup Configuration
===============================

Rsync to Remote Server
---------------------

.. code-block:: bash

   # Configure SSH key authentication first
   ssh-keygen -t rsa -b 4096 -f /root/.ssh/backup_key
   ssh-copy-id -i /root/.ssh/backup_key.pub backup-user@backup-server
   
   # Rsync backup script
   cat > /usr/local/bin/offsite-backup.sh << 'EOF'
   #!/bin/bash
   
   BACKUP_SOURCE="/backup/"
   REMOTE_HOST="backup-server"
   REMOTE_USER="backup-user"
   REMOTE_PATH="/remote/backup/proxmox/"
   SSH_KEY="/root/.ssh/backup_key"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   log "Starting offsite backup sync..."
   
   # Sync backups to remote server
   rsync -avz --delete \
       -e "ssh -i $SSH_KEY" \
       "$BACKUP_SOURCE" \
       "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
   
   if [ $? -eq 0 ]; then
       log "Offsite backup sync completed successfully"
   else
       log "ERROR: Offsite backup sync failed"
       exit 1
   fi
   EOF
   
   chmod +x /usr/local/bin/offsite-backup.sh

Cloud Storage Backup
--------------------

.. code-block:: bash

   # Install rclone for cloud storage
   curl https://rclone.org/install.sh | sudo bash
   
   # Configure cloud storage (example: AWS S3)
   rclone config
   
   # Cloud backup script
   cat > /usr/local/bin/cloud-backup.sh << 'EOF'
   #!/bin/bash
   
   BACKUP_SOURCE="/backup/"
   CLOUD_REMOTE="s3:proxmox-backups"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   log "Starting cloud backup sync..."
   
   # Sync to cloud storage
   rclone sync "$BACKUP_SOURCE" "$CLOUD_REMOTE" --progress
   
   if [ $? -eq 0 ]; then
       log "Cloud backup sync completed successfully"
   else
       log "ERROR: Cloud backup sync failed"
       exit 1
   fi
   EOF
   
   chmod +x /usr/local/bin/cloud-backup.sh

⏰ Backup Scheduling
===================

Cron Configuration
-----------------

.. code-block:: bash

   # Edit root crontab
   crontab -e
   
   # Add backup schedules
   # Daily VM backups at 2 AM (handled by Proxmox backup jobs)
   # Daily configuration backup at 3 AM
   0 3 * * * /usr/local/bin/config-backup.sh
   
   # ZFS snapshots every 6 hours
   0 */6 * * * /usr/local/bin/zfs-snapshot.sh
   
   # Database backup daily at 4 AM
   0 4 * * * /usr/local/bin/db-backup.sh
   
   # Offsite sync daily at 5 AM
   0 5 * * * /usr/local/bin/offsite-backup.sh
   
   # Cloud sync weekly on Sunday at 6 AM
   0 6 * * 0 /usr/local/bin/cloud-backup.sh

Systemd Timer Alternative
------------------------

.. code-block:: bash

   # Create systemd service for backup
   cat > /etc/systemd/system/proxmox-backup.service << 'EOF'
   [Unit]
   Description=Proxmox Configuration Backup
   
   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/config-backup.sh
   User=root
   EOF
   
   # Create systemd timer
   cat > /etc/systemd/system/proxmox-backup.timer << 'EOF'
   [Unit]
   Description=Run Proxmox backup daily
   Requires=proxmox-backup.service
   
   [Timer]
   OnCalendar=daily
   Persistent=true
   
   [Install]
   WantedBy=timers.target
   EOF
   
   # Enable and start timer
   systemctl daemon-reload
   systemctl enable proxmox-backup.timer
   systemctl start proxmox-backup.timer

🔄 Recovery Procedures
=====================

VM/Container Recovery
--------------------

.. code-block:: bash

   # List available backups
   pvesm list backup-storage
   
   # Restore VM from backup
   qmrestore /backup/vzdump-qemu-100-2024_12_01-02_00_00.vma.zst 100
   
   # Restore container from backup
   pct restore 200 /backup/vzdump-lxc-200-2024_12_01-02_00_00.tar.zst
   
   # Restore to different VM ID
   qmrestore /backup/vzdump-qemu-100-2024_12_01-02_00_00.vma.zst 101

Configuration Recovery
---------------------

.. code-block:: bash

   # Extract configuration backup
   cd /tmp
   tar -xzf /backup/configs/pve-config-20241201_020000.tar.gz
   
   # Restore specific configurations (be careful!)
   # Always backup current config first
   cp -r /etc/pve /etc/pve.backup.$(date +%Y%m%d)
   
   # Restore network configuration
   cp etc/network/interfaces /etc/network/interfaces
   systemctl restart networking

ZFS Recovery
-----------

.. code-block:: bash

   # Rollback to snapshot
   zfs rollback ZFS01/Data01@backup-20241201_020000
   
   # Clone snapshot for testing
   zfs clone ZFS01/Data01@backup-20241201_020000 ZFS01/Data01-test
   
   # Restore from remote snapshot
   ssh backup-server "zfs send backup-pool/proxmox-data@backup-20241201" | zfs receive ZFS01/Data01-restored

📊 Backup Monitoring
====================

Backup Verification Script
--------------------------

.. code-block:: bash

   cat > /usr/local/bin/backup-verify.sh << 'EOF'
   #!/bin/bash
   
   BACKUP_DIR="/backup"
   ALERT_EMAIL="admin@example.com"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   # Check if backups exist and are recent
   check_backup_age() {
       local backup_pattern="$1"
       local max_age_hours="$2"
       
       latest_backup=$(find "$BACKUP_DIR" -name "$backup_pattern" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
       
       if [ -z "$latest_backup" ]; then
           log "ERROR: No backups found matching pattern: $backup_pattern"
           return 1
       fi
       
       backup_age_hours=$(( ($(date +%s) - $(stat -c %Y "$latest_backup")) / 3600 ))
       
       if [ $backup_age_hours -gt $max_age_hours ]; then
           log "ERROR: Latest backup is $backup_age_hours hours old (max: $max_age_hours)"
           log "File: $latest_backup"
           return 1
       else
           log "OK: Latest backup is $backup_age_hours hours old"
           log "File: $latest_backup"
           return 0
       fi
   }
   
   # Verify backups
   log "Starting backup verification..."
   
   check_backup_age "pve-config-*.tar.gz" 25
   check_backup_age "docker-configs-*.tar.gz" 25
   
   log "Backup verification completed"
   EOF
   
   chmod +x /usr/local/bin/backup-verify.sh

Backup Status Dashboard
----------------------

.. code-block:: bash

   cat > /usr/local/bin/backup-status.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Proxmox Backup Status Report ==="
   echo "Generated: $(date)"
   echo
   
   echo "=== Proxmox Backup Jobs ==="
   pvesh get /cluster/backup
   echo
   
   echo "=== Recent Backup Files ==="
   find /backup -name "*.tar.gz" -o -name "*.vma.zst" -o -name "*.tar.zst" | head -10 | while read file; do
       echo "$(ls -lh "$file" | awk '{print $5, $6, $7, $8, $9}')"
   done
   echo
   
   echo "=== Storage Usage ==="
   df -h /backup
   echo
   
   echo "=== ZFS Snapshots ==="
   zfs list -t snapshot | tail -10
   EOF
   
   chmod +x /usr/local/bin/backup-status.sh

📋 Backup Checklist
===================

Daily Backup Verification:

- [ ] **VM/Container backups** completed successfully
- [ ] **Configuration backups** created
- [ ] **ZFS snapshots** taken
- [ ] **Database backups** completed (if applicable)
- [ ] **Backup storage** has sufficient space
- [ ] **Offsite sync** completed
- [ ] **Backup logs** reviewed for errors

Weekly Backup Tasks:

- [ ] **Test restore procedure** on non-critical VM
- [ ] **Verify backup integrity** with verification script
- [ ] **Clean old backups** according to retention policy
- [ ] **Update backup documentation** if needed
- [ ] **Review storage usage** and capacity planning

Monthly Backup Tasks:

- [ ] **Full disaster recovery test**
- [ ] **Review and update** backup procedures
- [ ] **Test offsite backup** restoration
- [ ] **Audit backup security** and access controls

🚨 Troubleshooting
=================

Common Backup Issues
-------------------

**Backup Job Fails**:

.. code-block:: bash

   # Check backup job logs
   journalctl -u vzdump@*
   
   # Check storage space
   df -h
   
   # Verify VM/container status
   qm status 100
   pct status 200

**Slow Backup Performance**:

.. code-block:: bash

   # Check I/O performance
   iostat -x 1
   
   # Monitor backup progress
   tail -f /var/log/vzdump.log

**Restore Failures**:

.. code-block:: bash

   # Verify backup file integrity
   file /backup/vzdump-qemu-100-*.vma.zst
   
   # Check available storage space
   df -h
   
   # Verify backup format compatibility
   qmrestore --help

📚 Additional Resources
======================

- `Proxmox VE Backup and Restore <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_vzdump>`__
- `ZFS Snapshots and Backup <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_zfs>`__
- `Backup Best Practices <https://pve.proxmox.com/wiki/Backup_and_Restore>`__

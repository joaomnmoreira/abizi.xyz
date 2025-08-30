=======================
Storage Configuration
=======================

.. highlight:: console

Comprehensive storage setup for Proxmox VE including ZFS configuration and directory management.

📋 Storage Overview
==================

Proxmox VE supports multiple storage types:

- **Local**: Direct attached storage (DAS)
- **ZFS**: Advanced filesystem with snapshots and compression
- **LVM**: Logical Volume Manager
- **Network Storage**: NFS, iSCSI, Ceph
- **Cloud Storage**: Various cloud providers

🔧 Initial Storage Reconfiguration
=================================

Remove Local-LVM and Extend Root
--------------------------------

By default, Proxmox creates a small root partition and large local-lvm. For single-node setups, it's often better to use all space for root:

.. code-block:: bash

   # Remove local-lvm storage
   lvremove /dev/pve/data
   
   # Extend root partition to use all available space
   lvresize -l +100%FREE /dev/pve/root
   resize2fs /dev/mapper/pve-root
   
   # Verify the change
   df -h

Update Storage Configuration
---------------------------

In Proxmox web interface:

1. **Datacenter** → **Storage**
2. **Remove** ``local-lvm`` storage
3. **Edit** ``local`` storage
4. **Enable all content types**: VZDump backup, ISO image, Container template, Disk image, Container, Snippets

🗄️ ZFS Storage Setup
====================

ZFS provides advanced features like snapshots, compression, and data integrity checking.

ZFS Pool Creation
----------------

Create ZFS storage pool:

.. code-block:: bash

   # Wipe existing partitions on target disks
   wipefs -a /dev/sdb /dev/sdc
   
   # Create ZFS pool (adjust disk names as needed)
   zpool create -f ZFS01 /dev/sdb /dev/sdc
   
   # Create dataset with mountpoint
   zfs create ZFS01/Data01
   zfs set mountpoint=/zfsdata ZFS01/Data01

ZFS Configuration Options
------------------------

Optimize ZFS for your use case:

.. code-block:: bash

   # Enable compression (saves space, improves performance)
   zfs set compression=lz4 ZFS01/Data01
   
   # Set recordsize for VM images (improves performance)
   zfs set recordsize=64K ZFS01/Data01
   
   # Enable deduplication (use carefully, requires lots of RAM)
   # zfs set dedup=on ZFS01/Data01

Add ZFS Storage to Proxmox
-------------------------

In Proxmox web interface:

1. **Datacenter** → **Storage** → **Add** → **Directory**
2. **Configuration**:
   - **ID**: ``ZFSData01``
   - **Directory**: ``/zfsdata``
   - **Content**: Select all needed types
   - **Shared**: No (unless using shared storage)

📁 Directory Structure Setup
===========================

Create organized directory structure for different services:

.. code-block:: bash

   # Main storage directories
   mkdir -p /zfsdata/{vms,containers,backups,iso,templates}
   
   # Docker service directories
   mkdir -p /docker/{transmission/{data,watch},prowlarr/config,radarr/config,bazarr/config}
   
   # Media storage (adjust path based on your setup)
   mkdir -p /mnt/nas-library/MULTIMEDIA/{movies,tv-shows,Downloads/{complete,incomplete}}
   
   # Backup directories
   mkdir -p /backup/{proxmox,docker-configs,media-metadata}

Set Proper Permissions
----------------------

.. code-block:: bash

   # Create service user
   adduser arr-stack --uid 1002 --disabled-password --gecos ""
   
   # Set permissions for Docker directories
   chown -R 1002:1002 /docker/
   
   # Set permissions for media directories
   chown -R 1002:1002 /mnt/nas-library/MULTIMEDIA/
   
   # Backup directory permissions
   chown -R root:root /backup/
   chmod 750 /backup/

🌐 Network Storage Configuration
===============================

NFS Storage Setup
----------------

For network-attached storage:

.. code-block:: bash

   # Install NFS client
   apt install nfs-common
   
   # Create mount point
   mkdir -p /mnt/nas-storage
   
   # Add to fstab for persistent mounting
   echo "192.168.1.100:/volume1/proxmox /mnt/nas-storage nfs defaults 0 0" >> /etc/fstab
   
   # Mount immediately
   mount -a

Add NFS to Proxmox:

1. **Datacenter** → **Storage** → **Add** → **NFS**
2. **Configuration**:
   - **ID**: ``NAS-Storage``
   - **Server**: ``192.168.1.100``
   - **Export**: ``/volume1/proxmox``
   - **Content**: Select appropriate types

iSCSI Storage Setup
------------------

For iSCSI targets:

.. code-block:: bash

   # Install iSCSI initiator
   apt install open-iscsi
   
   # Discover iSCSI targets
   iscsiadm -m discovery -t st -p 192.168.1.200
   
   # Login to target
   iscsiadm -m node --login

📊 Storage Monitoring
====================

Monitor storage usage and health:

.. code-block:: bash

   # Check disk usage
   df -h
   
   # ZFS pool status
   zpool status
   
   # ZFS dataset usage
   zfs list
   
   # Check for disk errors
   dmesg | grep -i error

Storage Health Script
--------------------

Create monitoring script:

.. code-block:: bash

   cat > /usr/local/bin/storage-health.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Storage Health Report ==="
   echo "Date: $(date)"
   echo
   
   echo "=== Disk Usage ==="
   df -h
   echo
   
   echo "=== ZFS Pool Status ==="
   zpool status
   echo
   
   echo "=== ZFS Dataset Usage ==="
   zfs list
   echo
   
   echo "=== Recent Disk Errors ==="
   dmesg | grep -i error | tail -10
   EOF
   
   chmod +x /usr/local/bin/storage-health.sh

🔄 Backup Configuration
======================

Automated Backup Setup
----------------------

Configure automated backups for critical data:

.. code-block:: bash

   # Create backup script
   cat > /usr/local/bin/storage-backup.sh << 'EOF'
   #!/bin/bash
   
   BACKUP_DIR="/backup"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   # Backup Proxmox configuration
   tar -czf "$BACKUP_DIR/pve-config-$DATE.tar.gz" /etc/pve/
   
   # Backup Docker configurations
   tar -czf "$BACKUP_DIR/docker-configs-$DATE.tar.gz" /docker/
   
   # ZFS snapshot (if using ZFS)
   zfs snapshot ZFS01/Data01@backup-$DATE
   
   # Clean old backups (keep 7 days)
   find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
   
   # Clean old ZFS snapshots (keep 14 days)
   zfs list -t snapshot | grep backup- | awk '{print $1}' | while read snap; do
       creation=$(zfs get -H -o value creation "$snap")
       if [[ $(date -d "$creation" +%s) -lt $(date -d "14 days ago" +%s) ]]; then
           zfs destroy "$snap"
       fi
   done
   EOF
   
   chmod +x /usr/local/bin/storage-backup.sh

Schedule Backups
---------------

Add to crontab:

.. code-block:: bash

   # Edit root crontab
   crontab -e
   
   # Add daily backup at 2 AM
   0 2 * * * /usr/local/bin/storage-backup.sh

🚨 Troubleshooting
=================

Common Storage Issues
--------------------

**ZFS Pool Import Issues**:

.. code-block:: bash

   # Force import pool
   zpool import -f ZFS01
   
   # Check pool status
   zpool status ZFS01

**Mount Issues**:

.. code-block:: bash

   # Check mount status
   mount | grep zfs
   
   # Remount if needed
   zfs mount ZFS01/Data01

**Permission Issues**:

.. code-block:: bash

   # Reset permissions
   chown -R 1002:1002 /docker/
   chmod -R 755 /docker/

📋 Storage Configuration Checklist
==================================

After storage configuration:

- [ ] **Root partition extended** and local-lvm removed
- [ ] **ZFS pool created** and mounted
- [ ] **Directory structure** organized
- [ ] **Permissions set** correctly
- [ ] **Network storage** configured (if applicable)
- [ ] **Backup procedures** implemented
- [ ] **Monitoring scripts** installed
- [ ] **Storage added** to Proxmox web interface

📚 Additional Resources
======================

- `Proxmox VE Storage Guide <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_storage>`__
- `ZFS Administration Guide <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_zfs>`__
- `Storage Configuration Examples <https://pve.proxmox.com/wiki/Storage>`__

================
Troubleshooting
================

.. highlight:: console

Common issues and solutions for Proxmox infrastructure troubleshooting.

🔧 System-Level Issues
======================

Boot and Startup Problems
-------------------------

**System Won't Boot**:

.. code-block:: bash

   # Boot from rescue mode or live USB
   # Mount root filesystem
   mount /dev/mapper/pve-root /mnt
   
   # Check filesystem integrity
   fsck /dev/mapper/pve-root
   
   # Check GRUB configuration
   chroot /mnt
   update-grub
   grub-install /dev/sda

**Kernel Panic Issues**:

.. code-block:: bash

   # Boot with previous kernel from GRUB menu
   # Remove problematic kernel
   apt remove pve-kernel-problematic-version
   
   # Check hardware compatibility
   dmesg | grep -i error
   
   # Disable problematic modules
   echo "blacklist module_name" >> /etc/modprobe.d/blacklist.conf

**Service Startup Failures**:

.. code-block:: bash

   # Check service status
   systemctl status pveproxy pvedaemon pve-cluster
   
   # Check service logs
   journalctl -u pveproxy -f
   journalctl -u pvedaemon -f
   journalctl -u pve-cluster -f
   
   # Restart services in order
   systemctl restart pve-cluster
   systemctl restart pvedaemon
   systemctl restart pveproxy

Network Connectivity Issues
--------------------------

**No Network Access**:

.. code-block:: bash

   # Check interface status
   ip link show
   ip addr show
   
   # Check bridge configuration
   brctl show
   
   # Restart networking
   systemctl restart networking
   
   # Check routing table
   ip route show
   
   # Test connectivity
   ping -c 3 8.8.8.8

**Bridge Configuration Problems**:

.. code-block:: bash

   # Recreate bridge
   ip link del vmbr0
   systemctl restart networking
   
   # Check interface configuration
   cat /etc/network/interfaces
   
   # Verify bridge creation
   brctl show vmbr0

**DNS Resolution Issues**:

.. code-block:: bash

   # Check DNS configuration
   cat /etc/resolv.conf
   
   # Test DNS resolution
   nslookup google.com
   dig google.com
   
   # Flush DNS cache
   systemctl restart systemd-resolved

🗄️ Storage Issues
=================

ZFS Problems
-----------

**Pool Import Failures**:

.. code-block:: bash

   # Check pool status
   zpool status
   
   # Force import pool
   zpool import -f poolname
   
   # Import pool with different name
   zpool import poolname newpoolname
   
   # Check for pool corruption
   zpool scrub poolname

**Dataset Mount Issues**:

.. code-block:: bash

   # Check mount status
   zfs list
   mount | grep zfs
   
   # Force mount dataset
   zfs mount -a
   zfs mount poolname/dataset
   
   # Check mount properties
   zfs get mountpoint poolname/dataset

**Performance Issues**:

.. code-block:: bash

   # Check I/O statistics
   zpool iostat -v 1
   
   # Check ARC statistics
   cat /proc/spl/kstat/zfs/arcstats
   
   # Adjust ARC size
   echo 4294967296 > /sys/module/zfs/parameters/zfs_arc_max

Disk and Filesystem Issues
--------------------------

**Disk Full Errors**:

.. code-block:: bash

   # Check disk usage
   df -h
   du -sh /* | sort -hr
   
   # Find large files
   find / -type f -size +1G -exec ls -lh {} \;
   
   # Clean up logs
   journalctl --vacuum-time=7d
   
   # Clean package cache
   apt clean

**Filesystem Corruption**:

.. code-block:: bash

   # Check filesystem
   fsck -f /dev/mapper/pve-root
   
   # Force check on next boot
   touch /forcefsck
   
   # Check for bad blocks
   badblocks -v /dev/sda

**LVM Issues**:

.. code-block:: bash

   # Scan for LVM volumes
   pvscan
   vgscan
   lvscan
   
   # Activate volume group
   vgchange -ay pve
   
   # Check LVM status
   pvdisplay
   vgdisplay
   lvdisplay

🖥️ Virtualization Issues
========================

VM Problems
----------

**VM Won't Start**:

.. code-block:: bash

   # Check VM configuration
   qm config 100
   
   # Check VM status
   qm status 100
   
   # Check for lock files
   ls -la /var/lock/qemu-server/
   rm /var/lock/qemu-server/lock-100.conf
   
   # Start VM with debug
   qm start 100 --debug

**VM Performance Issues**:

.. code-block:: bash

   # Check VM resource usage
   qm monitor 100
   info cpus
   info memory
   info block
   
   # Check host resources
   htop
   iotop
   
   # Adjust VM resources
   qm set 100 --memory 4096
   qm set 100 --cores 4

**VM Network Issues**:

.. code-block:: bash

   # Check VM network configuration
   qm config 100 | grep net
   
   # Check bridge connectivity
   brctl show
   
   # Test network from VM
   qm guest exec 100 -- ping -c 3 8.8.8.8

Container Problems
-----------------

**Container Won't Start**:

.. code-block:: bash

   # Check container configuration
   pct config 200
   
   # Check container status
   pct status 200
   
   # Check for errors
   journalctl -u pve-container@200
   
   # Force stop and start
   pct stop 200 --force
   pct start 200

**Container Resource Issues**:

.. code-block:: bash

   # Check container resources
   pct exec 200 -- free -h
   pct exec 200 -- df -h
   
   # Adjust container limits
   pct set 200 --memory 2048
   pct set 200 --rootfs local-lvm:16

**Privileged Container Issues**:

.. code-block:: bash

   # Enable privileged mode
   pct set 200 --unprivileged 0
   
   # Enable nesting for Docker
   pct set 200 --features nesting=1,keyctl=1
   
   # Check AppArmor issues
   aa-status
   aa-complain /usr/bin/lxc-start

🐳 Docker Issues
===============

Docker Service Problems
-----------------------

**Docker Won't Start**:

.. code-block:: bash

   # Check Docker status
   systemctl status docker
   
   # Check Docker logs
   journalctl -u docker -f
   
   # Restart Docker
   systemctl restart docker
   
   # Check Docker daemon configuration
   cat /etc/docker/daemon.json

**Container Issues**:

.. code-block:: bash

   # Check container status
   docker ps -a
   
   # Check container logs
   docker logs container-name
   
   # Restart container
   docker restart container-name
   
   # Execute into container
   docker exec -it container-name bash

**Docker Compose Issues**:

.. code-block:: bash

   # Check compose file syntax
   docker-compose config
   
   # View service logs
   docker-compose logs service-name
   
   # Recreate services
   docker-compose down
   docker-compose up -d
   
   # Force recreate
   docker-compose up -d --force-recreate

Storage and Volume Issues
------------------------

.. code-block:: bash

   # Check Docker storage usage
   docker system df
   
   # Clean up unused resources
   docker system prune -a
   
   # Check volume mounts
   docker volume ls
   docker volume inspect volume-name
   
   # Fix permission issues
   chown -R 1002:1002 /docker/service-name/

🌐 Web Interface Issues
======================

Proxmox Web GUI Problems
------------------------

**Can't Access Web Interface**:

.. code-block:: bash

   # Check pveproxy service
   systemctl status pveproxy
   systemctl restart pveproxy
   
   # Check firewall
   iptables -L
   
   # Check listening ports
   netstat -tlnp | grep :8006
   
   # Check SSL certificates
   ls -la /etc/pve/local/pve-ssl.*

**Authentication Issues**:

.. code-block:: bash

   # Reset root password
   passwd root
   
   # Check PAM configuration
   cat /etc/pam.d/proxmox-ve-auth
   
   # Clear browser cache and cookies
   # Try incognito/private browsing mode

**Performance Issues**:

.. code-block:: bash

   # Check system load
   uptime
   htop
   
   # Check memory usage
   free -h
   
   # Restart web services
   systemctl restart pveproxy pvedaemon

🔍 Diagnostic Tools
==================

System Diagnostics
------------------

.. code-block:: bash

   cat > /usr/local/bin/system-diagnostics.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Proxmox System Diagnostics ==="
   echo "Generated: $(date)"
   echo
   
   echo "=== System Information ==="
   pveversion
   uname -a
   uptime
   echo
   
   echo "=== CPU Information ==="
   lscpu | head -20
   echo
   
   echo "=== Memory Usage ==="
   free -h
   echo
   
   echo "=== Disk Usage ==="
   df -h
   echo
   
   echo "=== Network Interfaces ==="
   ip addr show
   echo
   
   echo "=== Bridge Status ==="
   brctl show
   echo
   
   echo "=== Service Status ==="
   systemctl status pveproxy pvedaemon pve-cluster --no-pager
   echo
   
   echo "=== VM Status ==="
   qm list
   echo
   
   echo "=== Container Status ==="
   pct list
   echo
   
   echo "=== Storage Status ==="
   zpool status 2>/dev/null || echo "No ZFS pools found"
   echo
   
   echo "=== Recent Errors ==="
   journalctl --since "1 hour ago" --priority=err --no-pager
   EOF
   
   chmod +x /usr/local/bin/system-diagnostics.sh

Network Diagnostics
-------------------

.. code-block:: bash

   cat > /usr/local/bin/network-diagnostics.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Network Diagnostics ==="
   echo "Generated: $(date)"
   echo
   
   echo "=== Interface Status ==="
   ip link show
   echo
   
   echo "=== IP Configuration ==="
   ip addr show
   echo
   
   echo "=== Routing Table ==="
   ip route show
   echo
   
   echo "=== DNS Configuration ==="
   cat /etc/resolv.conf
   echo
   
   echo "=== Connectivity Tests ==="
   ping -c 3 8.8.8.8
   echo
   
   echo "=== DNS Resolution Test ==="
   nslookup google.com
   echo
   
   echo "=== Port Listening ==="
   netstat -tlnp
   echo
   
   echo "=== Bridge Configuration ==="
   brctl show
   echo
   
   echo "=== Firewall Rules ==="
   iptables -L -n
   EOF
   
   chmod +x /usr/local/bin/network-diagnostics.sh

Performance Diagnostics
-----------------------

.. code-block:: bash

   cat > /usr/local/bin/performance-diagnostics.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Performance Diagnostics ==="
   echo "Generated: $(date)"
   echo
   
   echo "=== System Load ==="
   uptime
   echo
   
   echo "=== CPU Usage ==="
   top -bn1 | head -20
   echo
   
   echo "=== Memory Usage ==="
   free -h
   cat /proc/meminfo | head -10
   echo
   
   echo "=== Disk I/O ==="
   iostat -x 1 3
   echo
   
   echo "=== Network I/O ==="
   cat /proc/net/dev
   echo
   
   echo "=== Process List ==="
   ps aux --sort=-%cpu | head -20
   echo
   
   echo "=== Disk Usage ==="
   df -h
   echo
   
   echo "=== ZFS ARC Stats ==="
   if [ -f /proc/spl/kstat/zfs/arcstats ]; then
       grep -E "^(hits|misses|c|size)" /proc/spl/kstat/zfs/arcstats
   fi
   EOF
   
   chmod +x /usr/local/bin/performance-diagnostics.sh

📋 Emergency Procedures
======================

System Recovery
--------------

**Boot from Rescue Mode**:

1. Boot from Proxmox installation media
2. Select "Rescue Boot" or "Debug Mode"
3. Mount root filesystem: `mount /dev/mapper/pve-root /mnt`
4. Chroot into system: `chroot /mnt`
5. Fix issues and update GRUB: `update-grub`

**Reset to Factory Defaults**:

.. code-block:: bash

   # Backup important data first!
   # Reset network configuration
   cp /etc/network/interfaces.orig /etc/network/interfaces
   
   # Reset Proxmox configuration (DANGEROUS!)
   rm -rf /etc/pve/*
   
   # Reinitialize cluster
   pvecm create proxmox

**Data Recovery**:

.. code-block:: bash

   # Mount backup storage
   mount /dev/sdb1 /mnt/backup
   
   # Restore from backup
   qmrestore /mnt/backup/vzdump-qemu-100.vma.zst 100
   
   # Restore configuration
   tar -xzf /mnt/backup/pve-config.tar.gz -C /

🚨 Critical Issue Response
=========================

Service Outage Response
----------------------

1. **Immediate Assessment**:
   - Check system status: `systemctl status`
   - Check resource usage: `htop`, `df -h`
   - Check network connectivity: `ping 8.8.8.8`

2. **Service Recovery**:
   - Restart critical services: `systemctl restart pveproxy pvedaemon`
   - Check VM/container status: `qm list`, `pct list`
   - Verify storage access: `zpool status`

3. **Communication**:
   - Notify stakeholders of outage
   - Provide regular status updates
   - Document incident for post-mortem

Data Loss Prevention
-------------------

.. code-block:: bash

   # Immediate backup of critical data
   tar -czf /tmp/emergency-backup-$(date +%Y%m%d_%H%M%S).tar.gz /etc/pve/
   
   # Stop services to prevent further damage
   systemctl stop pveproxy pvedaemon
   
   # Create ZFS snapshot if possible
   zfs snapshot rpool@emergency-$(date +%Y%m%d_%H%M%S)
   
   # Copy critical files to safe location
   rsync -av /etc/pve/ /mnt/backup/emergency-pve-config/

📞 Support Resources
===================

Getting Help
-----------

**Proxmox Community**:
- Forum: https://forum.proxmox.com/
- Documentation: https://pve.proxmox.com/pve-docs/
- Wiki: https://pve.proxmox.com/wiki/

**Log Collection for Support**:

.. code-block:: bash

   # Generate support bundle
   proxmox-backup-debug inspect datastore
   
   # Collect system information
   /usr/local/bin/system-diagnostics.sh > /tmp/system-info.txt
   
   # Collect relevant logs
   journalctl --since "24 hours ago" > /tmp/system-logs.txt

**Professional Support**:
- Proxmox Subscription: https://www.proxmox.com/en/proxmox-ve/pricing
- Enterprise Support: Available with subscription

📚 Additional Resources
======================

- `Proxmox VE Troubleshooting Guide <https://pve.proxmox.com/wiki/Troubleshooting>`__
- `System Recovery Procedures <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_system_administration>`__
- `Community Forum <https://forum.proxmox.com/>`__
- `Bug Tracker <https://bugzilla.proxmox.com/>`__

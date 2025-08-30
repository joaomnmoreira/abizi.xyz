========================
Post-Install Configuration
========================

.. highlight:: console

Essential configuration steps after fresh Proxmox VE installation.

🚀 Automated Setup
==================

**Community Scripts (Recommended)**:

- `Proxmox VE Post Install <https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install>`__ - Automated post-install configuration

**Video Tutorials**:

- `Post Install Configuration <https://www.youtube.com/watch?v=R0Zn0bdPwcw>`__ - Step-by-step post-install guide
- `Don't run Proxmox without these settings! <https://www.youtube.com/watch?v=VAJWUZ3sTSI>`__ - Essential configuration tips

**Custom Automated Script**:

Use the provided post-install automation script:

.. code-block:: bash

   # Download and run the post-install script
   wget -O - https://raw.githubusercontent.com/your-repo/proxmox-configs/main/scripts/post-install-setup.sh | bash

Or run the local script:

.. code-block:: bash

   chmod +x configs/scripts/post-install-setup.sh
   ./configs/scripts/post-install-setup.sh

**Configuration Files Available**:

The complete automated setup script:

.. literalinclude:: ../configs/scripts/post-install-setup.sh
   :language: bash
   :caption: post-install-setup.sh
   :linenos:

⚙️ Manual Configuration Steps
=============================

If you prefer manual configuration, follow these steps:

1. Storage Reconfiguration
-------------------------

Remove local-lvm and extend root partition:

.. code-block:: bash

   # Remove local-lvm storage
   lvremove /dev/pve/data
   
   # Extend root partition
   lvresize -l +100%FREE /dev/pve/root
   resize2fs /dev/mapper/pve-root

2. Repository Configuration
--------------------------

Disable enterprise repositories and add no-subscription:

.. code-block:: bash

   # Disable enterprise repos
   sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
   
   # Add no-subscription repository
   echo "deb http://download.proxmox.com/debian/pve $(lsb_release -cs) pve-no-subscription" >> /etc/apt/sources.list
   
   # Update packages
   apt update && apt upgrade -y

3. Disable Enterprise Popup
---------------------------

Remove the subscription nag screen:

.. code-block:: bash

   # Backup original file
   cp /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.bak
   
   # Disable popup
   sed -i "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
   
   # Restart proxy service
   systemctl restart pveproxy.service

4. Network Configuration
-----------------------

Configure network interfaces (example for static IP):

.. code-block:: bash

   # Edit network configuration
   nano /etc/network/interfaces

Example configuration:

.. code-block:: text

   auto lo
   iface lo inet loopback

   auto vmbr0
   iface vmbr0 inet static
       address 192.168.1.240/24
       gateway 192.168.1.1
       bridge-ports enp0s31f6
       bridge-stp off
       bridge-fd 0

Restart networking:

.. code-block:: bash

   systemctl restart networking

5. Install Essential Packages
----------------------------

.. code-block:: bash

   apt install -y curl wget vim htop iotop iftop ncdu tree git unzip

📋 Post-Configuration Checklist
===============================

After running the configuration:

- [ ] **Reboot system**: ``reboot``
- [ ] **Verify web access**: ``https://your-ip:8006``
- [ ] **Check storage**: Datacenter → Storage (local should show all content types)
- [ ] **Update system**: Node → Updates → Refresh → Upgrade
- [ ] **Configure backups**: Set up automated backup procedures
- [ ] **Deploy services**: Use Docker Compose stacks from ``configs/``

🔧 Configuration Files
=====================

All configuration scripts and templates are available in:

- **Automated script**: ``configs/scripts/post-install-setup.sh``
- **Network template**: ``configs/templates/network-interfaces.template``
- **Backup script**: Created at ``/usr/local/bin/proxmox-backup.sh``

📊 Verification Commands
=======================

Verify your configuration:

.. code-block:: bash

   # Check storage
   df -h
   
   # Check services
   systemctl status pveproxy pvedaemon pve-cluster
   
   # Check network
   ip addr show
   
   # Check repositories
   apt update

7. Configure Storage and Repositories
-------------------------------------

Configure storage and repository settings:

1. In 'Datacenter' - 'Storage', remove 'local-lvm'
2. In 'Node' - 'Shell', enter commands:

::
    
    lvremove /dev/pve/data
    lvresize -l +100%FREE /dev/pve/root
    resize2fs /dev/mapper/pve-root

3. In 'Datacenter' - 'Storage', edit 'local' and select all options in content
4. Configure Repositories:

- In 'Node' - 'Updates' - 'Repositories', select repository ENTERPRISE and PVE-ENTERPRISE and select DISABLE
- In 'Node' - 'Updates' - 'Repositories', add repository 'No-Subscription'
- In 'Node' - 'Updates', click REFRESH and then UPGRADE
- In GUI select REBOOT

8. Enable Notifications
-----------------------

Configure email notifications for system alerts:

.. code-block:: bash

   # Via Web Interface:
   # 1. Navigate to 'Datacenter' → 'Notifications'
   # 2. Add a new notification target: 'SMTP'
   # 3. Configure SMTP settings (server, port, authentication)
   # 4. In notification handler, modify 'default-matcher':
   #    - Select your SMTP notification target
   #    - Unselect 'mail-to-root'

9. Trusted TLS Certificates
---------------------------

Configure Let's Encrypt certificates for secure web access:

.. code-block:: bash

   # Via Web Interface:
   # 1. Navigate to 'Datacenter' → 'ACME'
   # 2. Add ACME Account (Let's Encrypt)
   # 3. Configure DNS challenge or HTTP challenge
   # 4. Request certificate for your domain
   # 5. Enable automatic renewal

🚨 Troubleshooting
=================

Common issues and solutions:

**Storage Issues**
- Verify LVM configuration: ``lvs``
- Check filesystem: ``df -h``

**Network Issues**
- Check interface status: ``ip link show``
- Verify bridge configuration: ``brctl show``

**Service Issues**
- Check logs: ``journalctl -u pveproxy``
- Restart services: ``systemctl restart pveproxy``

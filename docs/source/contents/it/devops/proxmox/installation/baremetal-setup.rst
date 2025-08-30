==================
Baremetal Setup
==================

.. highlight:: console

Hardware installation and initial Proxmox VE setup procedures.

📋 Hardware Requirements
=======================

Recommended specifications for Proxmox VE:

- **CPU**: 64-bit processor with virtualization support (Intel VT-x or AMD-V)
- **RAM**: Minimum 2GB, recommended 8GB+ for production
- **Storage**: SSD recommended for OS, additional drives for VM storage
- **Network**: Gigabit Ethernet, multiple NICs recommended

🔧 Installation Process
======================

Baremetal Installation Guide
---------------------------

Follow this comprehensive video guide for hardware setup:

- `HomeLab on a Slab - Mobile all-in-one ProxMox Homelab <https://www.youtube.com/watch?v=RD7hV0A2NOc>`__

Key Installation Steps:

1. **Download Proxmox VE ISO**
   - Get latest version from `Proxmox Downloads <https://www.proxmox.com/en/downloads>`__
   - Create bootable USB with Rufus, Etcher, or dd

2. **Boot from Installation Media**
   - Configure BIOS/UEFI for virtualization support
   - Enable Intel VT-x or AMD-V
   - Set boot priority to USB/DVD

3. **Installation Configuration**
   - Select target disk for Proxmox installation
   - Configure timezone and keyboard layout
   - Set root password and email
   - Configure network settings (IP, gateway, DNS)

4. **Initial Network Setup**
   - Configure management interface
   - Set static IP or DHCP as needed
   - Ensure network connectivity for web interface

📊 Post-Installation Verification
================================

After installation, verify the setup:

.. code-block:: bash

   # Check system status
   pveversion
   
   # Verify network configuration
   ip addr show
   
   # Check storage
   df -h
   
   # Test web interface access
   curl -k https://localhost:8006

🌐 Web Interface Access
======================

Access the Proxmox web interface:

- **URL**: ``https://your-server-ip:8006``
- **Username**: ``root``
- **Password**: Set during installation
- **Realm**: ``Linux PAM standard authentication``

🔧 Hardware Optimization
=======================

BIOS/UEFI Settings
-----------------

Essential BIOS settings for optimal performance:

- **Virtualization**: Enable Intel VT-x or AMD-V
- **IOMMU**: Enable for GPU/device passthrough
- **Power Management**: Disable C-states for stability
- **Boot Mode**: UEFI recommended over Legacy BIOS

Network Interface Configuration
------------------------------

For multiple network interfaces:

- **Management**: Dedicated interface for Proxmox web access
- **VM Traffic**: Separate interface(s) for virtual machine networking
- **Storage**: Optional dedicated network for storage traffic (iSCSI, NFS)

📝 Installation Notes
====================

Important considerations during installation:

**Storage Layout**
- Use SSD for Proxmox OS installation
- Reserve additional drives for VM storage
- Consider ZFS for advanced storage features

**Network Planning**
- Plan IP addressing scheme
- Consider VLAN requirements
- Document network configuration

**Security**
- Use strong root password
- Plan firewall configuration
- Consider SSH key authentication

🚀 Next Steps
=============

After successful baremetal installation:

1. **Post-Install Configuration**: Follow :doc:`post-install-config`
2. **Storage Setup**: Configure :doc:`storage-configuration`
3. **Network Configuration**: Set up bridges and VLANs
4. **Service Deployment**: Deploy services using :doc:`../services/media-automation-stack`

📚 Additional Resources
======================

- `Proxmox VE Administration Guide <https://pve.proxmox.com/pve-docs/>`__
- `Proxmox VE Installation Guide <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_installation>`__
- `Hardware Requirements <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#system_requirements>`__

====================
Networking Services
====================

.. highlight:: console

Network infrastructure services including pfSense firewall and OpenWRT router configurations.

📋 Network Services Overview
============================

Essential networking services for Proxmox infrastructure:

- **pfSense**: Enterprise firewall and router
- **OpenWRT**: Lightweight router firmware
- **Network Segmentation**: VLAN and bridge configuration
- **VPN Services**: WireGuard and OpenVPN setup

🔥 pfSense Configuration
=======================

pfSense provides enterprise-grade firewall and routing capabilities.

pfSense VM Setup
---------------

**References:**
- `Virtualizing An Internal Network With pfSense In ProxMox <https://www.youtube.com/watch?v=V6di1EAovN8>`__

VM Configuration Requirements:

.. code-block:: bash

   # Recommended VM specifications
   CPU: 2 cores
   RAM: 2GB minimum, 4GB recommended
   Storage: 20GB minimum
   Network: 2+ interfaces (WAN + LAN)

Network Interface Setup:

1. **WAN Interface**: Connected to external network (vmbr0)
2. **LAN Interface**: Connected to internal network (vmbr1)
3. **Optional DMZ**: Additional interface for DMZ network (vmbr2)

pfSense Installation Steps
-------------------------

1. **Download pfSense ISO**:
   - Get latest version from `pfSense Downloads <https://www.pfsense.org/download/>`__

2. **Create VM**:

   .. code-block:: bash

      # Create pfSense VM via CLI
      qm create 100 --name pfsense --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1

3. **Install pfSense**:
   - Boot from ISO and follow installation wizard
   - Configure WAN and LAN interfaces
   - Set initial IP addresses

4. **Web Interface Access**:
   - Default LAN IP: ``192.168.1.1``
   - Username: ``admin``
   - Password: ``pfsense``

pfSense Configuration
--------------------

Essential configuration steps:

**Basic Setup**:
1. **System** → **General Setup**: Configure hostname, domain, DNS
2. **Interfaces** → **Assignments**: Verify interface assignments
3. **System** → **Advanced** → **Networking**: Enable hardware checksum offloading

**Firewall Rules**:
1. **Firewall** → **Rules** → **LAN**: Configure LAN access rules
2. **Firewall** → **Rules** → **WAN**: Configure WAN access rules
3. **Firewall** → **NAT**: Configure port forwarding if needed

**DHCP Configuration**:
1. **Services** → **DHCP Server**: Configure DHCP for LAN
2. Set IP range, DNS servers, gateway

📡 OpenWRT Configuration
=======================

OpenWRT provides lightweight routing and wireless capabilities.

OpenWRT VM Setup
----------------

**References:**
- `How to install OpenWRT on Proxmox <https://www.youtube.com/watch?v=8RoYUsNe4gE>`__
- `How to set up an OpenWRT VM in Proxmox <https://gist.github.com/subrezon/b9aa2014343f934fbf69e579ecfc8da8>`__
- `Must-Have OpenWrt Router Setup For Your Proxmox <https://www.youtube.com/watch?v=3mPbrunpjpk>`__

VM Requirements:

.. code-block:: bash

   # OpenWRT VM specifications
   CPU: 1-2 cores
   RAM: 512MB minimum, 1GB recommended
   Storage: 1GB minimum
   Network: 2+ interfaces

OpenWRT Installation
-------------------

1. **Download OpenWRT Image**:
   - Get x86_64 image from `OpenWRT Downloads <https://downloads.openwrt.org/>`__

2. **Create VM**:

   .. code-block:: bash

      # Create OpenWRT VM
      qm create 101 --name openwrt --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0 --net1 virtio,bridge=vmbr1

3. **Upload and Configure**:
   - Upload OpenWRT image to Proxmox storage
   - Attach as IDE drive to VM
   - Boot and configure via console

OpenWRT Configuration
--------------------

Initial setup via console:

.. code-block:: bash

   # Set root password
   passwd
   
   # Configure network interfaces
   vi /etc/config/network
   
   # Configure wireless (if applicable)
   vi /etc/config/wireless
   
   # Restart network services
   /etc/init.d/network restart

Web Interface Configuration:

1. **Access LuCI**: ``http://192.168.1.1`` (default)
2. **Network** → **Interfaces**: Configure WAN/LAN interfaces
3. **Network** → **Wireless**: Configure wireless settings
4. **System** → **Administration**: Set passwords and SSH keys

🌐 Network Bridge Configuration
==============================

Configure Proxmox network bridges for different network segments.

Bridge Setup
-----------

Create additional bridges for network segmentation:

.. code-block:: bash

   # Edit network configuration
   nano /etc/network/interfaces

Example multi-bridge configuration:

.. code-block:: text

   # Management bridge (existing)
   auto vmbr0
   iface vmbr0 inet static
       address 192.168.1.240/24
       gateway 192.168.1.1
       bridge-ports enp0s31f6
       bridge-stp off
       bridge-fd 0

   # Internal LAN bridge
   auto vmbr1
   iface vmbr1 inet manual
       bridge-ports none
       bridge-stp off
       bridge-fd 0

   # DMZ bridge
   auto vmbr2
   iface vmbr2 inet manual
       bridge-ports none
       bridge-stp off
       bridge-fd 0

   # Storage network bridge
   auto vmbr3
   iface vmbr3 inet manual
       bridge-ports enp0s31f7
       bridge-stp off
       bridge-fd 0

Apply network changes:

.. code-block:: bash

   # Restart networking
   systemctl restart networking
   
   # Verify bridges
   brctl show

VLAN Configuration
-----------------

Configure VLANs for network segmentation:

.. code-block:: text

   # VLAN-aware bridge
   auto vmbr0
   iface vmbr0 inet manual
       bridge-ports enp0s31f6
       bridge-stp off
       bridge-fd 0
       bridge-vlan-aware yes
       bridge-vids 2-4094

   # VLAN interfaces
   auto vmbr0.10
   iface vmbr0.10 inet static
       address 192.168.10.1/24

   auto vmbr0.20
   iface vmbr0.20 inet static
       address 192.168.20.1/24

🔐 VPN Services
==============

Configure VPN services for remote access.

WireGuard Setup
--------------

Install and configure WireGuard:

.. code-block:: bash

   # Install WireGuard
   apt update
   apt install wireguard
   
   # Generate keys
   wg genkey | tee privatekey | wg pubkey > publickey
   
   # Create configuration
   nano /etc/wireguard/wg0.conf

Example WireGuard configuration:

.. code-block:: text

   [Interface]
   PrivateKey = <server-private-key>
   Address = 10.0.0.1/24
   ListenPort = 51820
   PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o vmbr0 -j MASQUERADE
   PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o vmbr0 -j MASQUERADE

   [Peer]
   PublicKey = <client-public-key>
   AllowedIPs = 10.0.0.2/32

Enable WireGuard:

.. code-block:: bash

   # Enable and start WireGuard
   systemctl enable wg-quick@wg0
   systemctl start wg-quick@wg0
   
   # Check status
   wg show

📊 Network Monitoring
====================

Monitor network performance and connectivity.

Network Monitoring Tools
-----------------------

.. code-block:: bash

   # Install monitoring tools
   apt install -y iftop nethogs nload vnstat
   
   # Monitor interface traffic
   iftop -i vmbr0
   
   # Monitor bandwidth by process
   nethogs vmbr0
   
   # Real-time network load
   nload vmbr0

Network Health Script
--------------------

Create network monitoring script:

.. code-block:: bash

   cat > /usr/local/bin/network-health.sh << 'EOF'
   #!/bin/bash
   
   echo "=== Network Health Report ==="
   echo "Date: $(date)"
   echo
   
   echo "=== Interface Status ==="
   ip link show
   echo
   
   echo "=== Bridge Status ==="
   brctl show
   echo
   
   echo "=== Routing Table ==="
   ip route show
   echo
   
   echo "=== Network Connectivity ==="
   ping -c 3 8.8.8.8
   echo
   
   echo "=== DNS Resolution ==="
   nslookup google.com
   EOF
   
   chmod +x /usr/local/bin/network-health.sh

🚨 Troubleshooting
=================

Common networking issues and solutions.

Bridge Issues
------------

.. code-block:: bash

   # Restart networking
   systemctl restart networking
   
   # Check bridge status
   brctl show
   
   # Verify interface status
   ip link show

VM Network Issues
----------------

.. code-block:: bash

   # Check VM network configuration
   qm config <vmid>
   
   # Restart VM networking
   qm reboot <vmid>

Firewall Issues
--------------

.. code-block:: bash

   # Check iptables rules
   iptables -L -n
   
   # Flush iptables (use carefully)
   iptables -F

📋 Network Configuration Checklist
==================================

After network configuration:

- [ ] **Bridges configured** and operational
- [ ] **pfSense VM** deployed and configured
- [ ] **OpenWRT VM** deployed (if needed)
- [ ] **VLAN configuration** implemented
- [ ] **VPN services** configured
- [ ] **Firewall rules** configured
- [ ] **Network monitoring** tools installed
- [ ] **Connectivity tested** between segments

📚 Additional Resources
======================

- `Proxmox VE Network Configuration <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_network_configuration>`__
- `pfSense Documentation <https://docs.netgate.com/pfsense/en/latest/>`__
- `OpenWRT Documentation <https://openwrt.org/docs/start>`__
- `WireGuard Documentation <https://www.wireguard.com/quickstart/>`__

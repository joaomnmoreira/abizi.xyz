================
Virtualization
================

.. highlight:: console

Virtual machine and container management in Proxmox VE including Docker deployment and VM optimization.

📋 Virtualization Overview
==========================

Proxmox VE supports multiple virtualization technologies:

- **KVM Virtual Machines**: Full virtualization with hardware emulation
- **LXC Containers**: Lightweight OS-level virtualization
- **Docker Containers**: Application containerization within LXC
- **GPU Passthrough**: Direct hardware access for VMs

🖥️ Virtual Machine Management
=============================

VM Creation and Configuration
-----------------------------

**VM Creation via Web Interface**:

1. **Create VM**: Datacenter → Node → Create VM
2. **General**: Set VM ID, name, and resource pool
3. **OS**: Select ISO image and OS type
4. **System**: Configure BIOS, machine type, and SCSI controller
5. **Hard Disk**: Set disk size, format, and storage location
6. **CPU**: Configure CPU type, cores, and sockets
7. **Memory**: Set RAM allocation
8. **Network**: Configure network interfaces

**VM Creation via CLI**:

.. code-block:: bash

   # Create Ubuntu VM example
   qm create 100 \
     --name ubuntu-server \
     --memory 2048 \
     --cores 2 \
     --net0 virtio,bridge=vmbr0 \
     --scsi0 local-lvm:32 \
     --ide2 local:iso/ubuntu-22.04-server.iso,media=cdrom \
     --boot c \
     --bootdisk scsi0 \
     --ostype l26

**Automated VM Creation with Packer**:

- `Create VMs on Proxmox in Seconds! <https://www.youtube.com/watch?v=1nf3WOEFq1Y>`__ - Comprehensive guide to using Packer for automated VM template creation

Linux VM Optimization
---------------------

Install QEMU Guest Agent for better integration:

.. code-block:: bash

   # Ubuntu/Debian
   sudo apt update
   sudo apt install qemu-guest-agent
   sudo systemctl enable qemu-guest-agent
   sudo systemctl start qemu-guest-agent

   # CentOS/RHEL
   sudo yum install qemu-guest-agent
   sudo systemctl enable qemu-guest-agent
   sudo systemctl start qemu-guest-agent

Enable in Proxmox:

1. **VM** → **Options** → **QEMU Guest Agent**: Enable
2. **Shutdown and restart** the VM

Windows VM Configuration
-----------------------

**VirtIO Drivers Installation**:

- Download VirtIO drivers ISO from `Proxmox VirtIO Drivers <https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers#Using_the_ISO>`__
- Attach ISO during Windows installation
- Install drivers for network, storage, and balloon

**Physical Drive Passthrough**:

Reference: `Passing a Physical Drive through to a VM in ProxMox <https://www.youtube.com/watch?v=U-UTMuhmC1U>`__

.. code-block:: bash

   # List available disks
   ls -n /dev/disk/by-id/
   
   # Add physical disk to VM
   /sbin/qm set [VM-ID] -virtio2 /dev/disk/by-id/[DISK-ID]

📦 LXC Container Management
==========================

Container Creation
-----------------

**Create LXC Container**:

.. code-block:: bash

   # Create Ubuntu LXC container
   pct create 200 \
     local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
     --hostname ubuntu-container \
     --memory 1024 \
     --cores 2 \
     --net0 name=eth0,bridge=vmbr0,ip=dhcp \
     --storage local-lvm \
     --rootfs local-lvm:8

**Container Configuration**:

.. code-block:: bash

   # Start container
   pct start 200
   
   # Enter container console
   pct enter 200
   
   # Set root password
   passwd

Container Optimization
---------------------

**Privileged vs Unprivileged**:
- **Privileged**: Full root access, better compatibility
- **Unprivileged**: Better security, limited functionality

**Resource Limits**:

.. code-block:: bash

   # Set CPU limit
   pct set 200 --cores 2 --cpulimit 1.5
   
   # Set memory limit
   pct set 200 --memory 1024 --swap 512

🐳 Docker in LXC Containers
===========================

Docker LXC Setup
----------------

**References**:
- `Running Docker under LXC Containers in ProxMox for Extra Granularization <https://www.youtube.com/watch?v=faoIeeZZ6ws>`__

**Create Docker-Ready LXC**:

1. **Create privileged container** (required for Docker)
2. **Enable nesting**: Options → Features → Nesting
3. **Configure keyctl**: Options → Features → Keyctl

**Docker Installation in LXC**:

.. code-block:: bash

   # Update system
   apt update && apt upgrade -y
   
   # Install required packages
   apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
   
   # Add Docker GPG key
   curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
   
   # Add Docker repository
   add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
   
   # Update package list
   apt update
   
   # Install Docker
   apt install docker-ce
   
   # Verify Docker installation
   systemctl status docker
   docker run hello-world
   
   # Install additional tools
   apt install cifs-utils docker-compose

Docker Service Configuration
---------------------------

**Create Docker service user**:

.. code-block:: bash

   # Create docker user
   adduser docker-user
   usermod -aG docker docker-user

**Configure Docker daemon**:

.. code-block:: bash

   # Create daemon configuration
   mkdir -p /etc/docker
   cat > /etc/docker/daemon.json << EOF
   {
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "10m",
       "max-file": "3"
     },
     "storage-driver": "overlay2"
   }
   EOF
   
   # Restart Docker
   systemctl restart docker

🔧 VM Templates and Automation
==============================

VM Template Creation
-------------------

**Create Packer Templates**:

Reference: `Create VMs on Proxmox in Seconds! <https://www.youtube.com/watch?v=1nf3WOEFq1Y>`__

**Manual Template Creation**:

1. **Install and configure** base VM
2. **Clean up** logs and temporary files
3. **Shutdown** VM
4. **Convert to template**: Right-click VM → Convert to template

**Clone from Template**:

.. code-block:: bash

   # Clone VM from template
   qm clone 9000 100 --name new-vm --full
   
   # Start cloned VM
   qm start 100

Cloud-Init Configuration
-----------------------

**Enable Cloud-Init**:

.. code-block:: bash

   # Add Cloud-Init drive
   qm set 100 --ide2 local-lvm:cloudinit
   
   # Configure Cloud-Init
   qm set 100 --ciuser ubuntu --cipassword password
   qm set 100 --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
   qm set 100 --nameserver 8.8.8.8
   qm set 100 --searchdomain local

📊 Performance Monitoring
=========================

VM Performance Monitoring
-------------------------

**Monitor VM Resources**:

.. code-block:: bash

   # Check VM status
   qm status 100
   
   # Monitor VM performance
   qm monitor 100
   
   # List all VMs
   qm list

**Performance Tuning**:

.. code-block:: bash

   # Enable NUMA
   qm set 100 --numa 1
   
   # Set CPU type
   qm set 100 --cpu host
   
   # Enable hardware acceleration
   qm set 100 --args '-cpu host,+aes'

Container Monitoring
-------------------

.. code-block:: bash

   # Check container status
   pct status 200
   
   # Monitor container resources
   pct exec 200 -- htop
   
   # List all containers
   pct list

🔄 Backup and Migration
======================

VM Backup Configuration
----------------------

**Automated Backups**:

1. **Datacenter** → **Backup**
2. **Add backup job**:
   - **Node**: Select target node
   - **Storage**: Backup destination
   - **Schedule**: Set backup frequency
   - **Selection**: Choose VMs/containers
   - **Retention**: Set backup retention policy

**Manual Backup**:

.. code-block:: bash

   # Backup VM
   vzdump 100 --storage local --compress gzip
   
   # Backup container
   vzdump 200 --storage local --compress lzo

VM Migration
-----------

**Live Migration**:

.. code-block:: bash

   # Migrate VM to another node
   qm migrate 100 node2
   
   # Migrate with storage
   qm migrate 100 node2 --targetstorage local-lvm

🚨 Troubleshooting
=================

Common VM Issues
---------------

**VM Won't Start**:

.. code-block:: bash

   # Check VM configuration
   qm config 100
   
   # Check system logs
   journalctl -u qemu-server@100
   
   # Reset VM
   qm reset 100

**Performance Issues**:

.. code-block:: bash

   # Check host resources
   htop
   iostat -x 1
   
   # Check VM disk usage
   qm monitor 100
   info blockstats

Container Issues
---------------

**Container Won't Start**:

.. code-block:: bash

   # Check container configuration
   pct config 200
   
   # Check container logs
   journalctl -u pve-container@200
   
   # Force stop and start
   pct stop 200 --force
   pct start 200

📋 Virtualization Checklist
===========================

After virtualization setup:

- [ ] **VM templates created** and tested
- [ ] **LXC containers** configured for services
- [ ] **Docker environment** set up in LXC
- [ ] **Guest agents installed** in VMs
- [ ] **Backup jobs configured** for critical VMs
- [ ] **Performance monitoring** implemented
- [ ] **Resource limits** configured appropriately
- [ ] **Network connectivity** verified

📚 Additional Resources
======================

- `Proxmox VE Virtual Machine Management <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_virtual_machines>`__
- `LXC Container Management <https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_pct>`__
- `Docker Documentation <https://docs.docker.com/>`__
- `QEMU Guest Agent <https://pve.proxmox.com/wiki/Qemu-guest-agent>`__

=======
Proxmox
=======

.. highlight:: console

Baremetal Installation
----------------------

- `HomeLab on a Slab - Mobile all-in-one ProxMox Homelab <https://www.youtube.com/watch?v=RD7hV0A2NOc>`__

Post Install Configuration
--------------------------

- References:

`Post Install Configuration <https://www.youtube.com/watch?v=R0Zn0bdPwcw>`__

1. In 'Datacenter' - 'Storage', remove 'local-lvm';
2. In 'Node' - 'Shell', enter commands:

::
    
    lvremove /dev/pve/data
    lvresize -l +100%FREE /dev/pve/root
    resize2fs /dev/mapper/pve-root

3. In 'Datacenter' - 'Storage', edit 'local' and select all options in content;
4. Configure Repositories:

- In 'Node' - 'Updates' - 'Repositories', select repository ENTERPRISE and PVE-ENTERPRISE and select DISABLE;
- In. 'Node' - 'Updates' - 'Repositories', add repository 'No-Subscription';
- In 'Node' - 'Updates', click REFRESH and then UPGRADE;
- In GUI select REBOOT.

5. Disable 'Enterprise Pop-up':

- Connect via SSH (putty):

::
    
    cd /usr/share/javascript/proxmox-widget-toolkit/
    cp proxmoxlib.js proxmoxlib.js.bak
    joe proxmoxlib.js

- In joe, search for 'No valid subscription' and change to: void({ //Ext.Msg.show({
- Save

::
    
    systemctl restart pveproxy.service

5. Change IP configuration:

- Connect via SSH (putty):

::
    
    cd /etc/network
    joe interfaces

- In editor, change from accordingly:

::
    
    auto vmbr0
        iface vmbr0 inet static
        address 192.168.1.240/24
        gateway 192.168.1.1
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0
    
Ou,

::
    
    auto vmbr0
        iface vmbr0 inet dhcp
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0

- Save

::
    
    systemctl restart networking

Storage Configuration
---------------------

- `Storage Configuration <https://www.youtube.com/watch?v=HqOGeqT-SCA>`__

#. In 'Node' - 'Disks', wipe Storage Disks;
#. In 'Node' - 'Disks' - 'ZFS', create storage;
#. Create ZFS mountpoint in shell:

::
    
    zfs create ZFS01/Data01 -a mountpoint=zfsdata

4. Create Directory in ZFS Partition:

- Select 'Datacenter' - 'Storage' - 'CREATE DIRECTORY'

::
    
    ID: ZFSData01
    Directory: /zfsdata
    Content: ALL SELECTED

pfSense
-------

- References:

`Virtualizing An Internal Network With pfSense In ProxMox <https://www.youtube.com/watch?v=V6di1EAovN8>`__

Docker
------

- References:

`Running Docker under LXC Containers in ProxMox for Extra Granularization <https://www.youtube.com/watch?v=faoIeeZZ6ws>`__

::

    $ apt update
    $ apt upgrade

    # Installing required packages
    $ apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common

    # add the docker gpg key
    $ curl -fsSL https://download.docker.com/linux/deb... | apt-key add -

    # add the docker repository
    $ add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

    # another apt update
    $ apt update

    # install docker
    $ apt install docker-ce

    # check that it’s running
    $ systemctl status docker

    # more packages
    $ apt install cifs-utils docker-compose

    # check that docker is functioning properly
    $ docker run hello-world

Virtual Machines
----------------

Linux
=====

::
    sudo apt install qemu-guest-agent

Windows
=======

- `Virtual drivers for Windows VM's <https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers#Using_the_ISO>`__
- `Passing a Physical Drive through to a VM in ProxMox <https://www.youtube.com/watch?v=U-UTMuhmC1U>`__

::
    ls -n /dev/disk/by-id/
    /sbin/qm set [VM-ID] -virtio2 /dev/disk/by-id/[DISK-ID]


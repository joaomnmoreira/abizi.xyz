=======
Proxmox
=======

.. highlight:: console

Baremetal Installation
----------------------

- `HomeLab on a Slab - Mobile all-in-one ProxMox Homelab <https://www.youtube.com/watch?v=RD7hV0A2NOc>`__

Post Install Configuration [NEW]
--------------------------------

- `Proxmox VE Post Install <https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install>`__
- `Proxmox VE Docker <https://community-scripts.github.io/ProxmoxVE/scripts?id=docker>`__



## Service References and Documentation

### Radarr (Movie Management)
- [Docker Hub - LinuxServer Radarr](https://hub.docker.com/r/linuxserver/radarr)
- [Guide to Radarr - Rapidseedbox](https://www.rapidseedbox.com/blog/guide-to-radarr)

### Transmission (Download Client)
- [Docker Hub - LinuxServer Transmission](https://hub.docker.com/r/linuxserver/transmission)

### Prowlarr (Indexer Manager)
- [Docker Hub - LinuxServer Prowlarr](https://hub.docker.com/r/linuxserver/prowlarr)
- [Prowlarr GitHub Repository](https://github.com/Prowlarr/Prowlarr)

### Bazarr (Subtitle Management)
- [Bazarr Setup Guide - Official Wiki](https://wiki.bazarr.media/Getting-Started/Setup-Guide/)

## Complete Workflow

Your full automated media pipeline:

1. **Add Movie** → Radarr web interface
2. **Search Indexers** → Prowlarr provides indexer sources to Radarr
3. **Download Movie** → Radarr sends torrent to Transmission
4. **Process Download** → Radarr moves completed file to movies folder
5. **Download Subtitles** → Bazarr automatically finds and downloads subtitles
6. **Ready to Watch** → Movie with subtitles available in movies folder

## Required Directory Setup

Create all required directories:

```bash

# Local Docker configuration directories (on container filesystem)
adduser arr-stack --uid 1002 --disabled-password
sudo mkdir -p /docker/{transmission/{data,watch},prowlarr/config,radarr/config,bazarr/config}

# Local Docker configuration directories (on container filesystem from host PROXMOX)
pct mount 23001
mounted CT 23001 in '/var/lib/lxc/23001/rootfs'
chown -R 1002:1002 /var/lib/lxc/23001/rootfs/docker/
pct unmount 23001

# Media directories (on NAS via iSCSI mount)
mkdir -p /mnt/nas-library/MULTIMEDIA/{movies,Downloads/{complete,incomplete}}

```

## Configuration Steps After Deployment

### Step 1: Access Web Interfaces

- **Transmission:** `http://your-host:9091` (username: jmoreira)
- **Prowlarr:** `http://your-host:9696`
- **Radarr:** `http://your-host:7878`
- **Bazarr:** `http://your-host:6767`

### Step 2: Configure Prowlarr (Indexer Manager)

1. **Add Indexers:** Settings → Indexers → Add Indexer
   - Add public trackers: The Pirate Bay, 1337x, RARBG
   - Or private trackers if you have accounts

2. **Connect to Radarr:** Settings → Apps → Add Application
   - **Type:** Radarr
   - **Prowlarr Server:** `http://prowlarr:9696`
   - **Radarr Server:** `http://radarr:7878`
   - **API Key:** Copy from Radarr → Settings → General

### Step 3: Configure Radarr (Movie Management)

1. **Verify Download Client:** Settings → Download Clients
   - Should show Transmission at `transmission:9091`

2. **Set Media Management:** Settings → Media Management
   - **Root Folder:** `/movies`
   - **Movie Naming:** Enable and configure format

3. **Check Indexers:** Settings → Indexers
   - Should auto-populate from Prowlarr

4. **Quality Profiles:** Settings → Profiles → Quality Profiles
   - Configure preferred quality (1080p, 4K, etc.)

### Step 4: Configure Bazarr (Subtitle Management)

1. **Languages:** Settings → Languages
   - Add Portuguese, English, or your preferred languages

2. **Connect to Radarr:** Settings → Radarr
   - **Address:** `http://radarr:7878`
   - **API Key:** Same as used in Prowlarr
   - **Base URL:** Leave empty
   - **Test** connection

3. **Subtitle Providers:** Settings → Providers
   - Enable OpenSubtitles, Subscene, or other providers
   - Some may require free registration

4. **Path Mappings:** Settings → General
   - Should auto-detect `/movies` path

### Step 5: Test the Complete Workflow

1. **Add a Movie in Radarr**
   - Movies → Add New → Search for a movie
   - Select quality profile → Add Movie

2. **Monitor Progress**
   - Radarr searches via Prowlarr indexers
   - Downloads via Transmission
   - Processes and moves to movies folder
   - Bazarr detects new movie and downloads subtitles

### Step 6: Automation Settings

**Radarr Automation:**
- Settings → General → Start-Up → Enable "Show advanced settings"
- Configure automatic search schedules

**Bazarr Automation:**
- Settings → Scheduler → Configure subtitle search frequency
- Settings → General → Enable "Automatic" subtitle download

## Service URLs Summary

- **Transmission:** `:9091` (Downloads)
- **Prowlarr:** `:9696` (Indexer Management)
- **Radarr:** `:7878` (Movie Management)
- **Bazarr:** `:6767` (Subtitle Management)

Post Install Configuration [OLD]
--------------------------------

- References:

`Post Install Configuration <https://www.youtube.com/watch?v=R0Zn0bdPwcw>`__
`Don’t run Proxmox without these settings! <https://www.youtube.com/watch?v=VAJWUZ3sTSI>`__

1. In 'Datacenter' - 'Storage', remove 'local-lvm';
2. In 'Node' - 'Shell', enter commands:

::
    
    lvremove /dev/pve/data
    lvresize -l +100%FREE /dev/pve/root
    resize2fs /dev/mapper/pve-root

3. In 'Datacenter' - 'Storage', edit 'local' and select all options in content;
4. Configure Repositories:

- In 'Node' - 'Updates' - 'Repositories', select repository ENTERPRISE and PVE-ENTERPRISE and select DISABLE;
- In 'Node' - 'Updates' - 'Repositories', add repository 'No-Subscription';
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

6. Change IP configuration:

- Connect via SSH (putty):

::
    
    cd /etc/network
    joe interfaces

- In editor, change from accordingly:

Static IP Address

::
    
    auto vmbr0
        iface vmbr0 inet static
        address 192.168.1.240/24
        gateway 192.168.1.1
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0
    
Or, Dynamic IP Address (DHCP)

::
    
    auto vmbr0
        iface vmbr0 inet dhcp
        bridge-ports enp0s31f6
        bridge-stp off
        bridge-fd 0

- Save

::
    
    systemctl restart networking

7. Enable Notifications:

In 'Datacenter' - 'Notifications':

- Add a new notification target, 'SMTP';
- In notification handler modify 'default-matcher' in 'Targets to notify':
  - Select previous added notification target;
  - Unselect 'mail-to-root'.

8. Trusted TLS Certificates:

In 'Datacenter' - 'ACME':

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

Create VM's with Packer
-----------------------

- `Create VMs on Proxmox in Seconds! <https://www.youtube.com/watch?v=1nf3WOEFq1Y>`__


pfSense
-------

- References:

`Virtualizing An Internal Network With pfSense In ProxMox <https://www.youtube.com/watch?v=V6di1EAovN8>`__

OpenWRT
-------

- References:

`How to install OpenWRT on Proxmox <https://www.youtube.com/watch?v=8RoYUsNe4gE>`__
`How to set up an OpenWRT VM in Proxmox <https://gist.github.com/subrezon/b9aa2014343f934fbf69e579ecfc8da8>`__
`Must-Have OpenWrt Router Setup For Your Proxmox <https://www.youtube.com/watch?v=3mPbrunpjpk>`__

Casa
-------

- References:

`How to install OpenWRT on Proxmox <https://www.youtube.com/watch?v=8RoYUsNe4gE>`__

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


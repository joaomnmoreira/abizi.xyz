=======================
Media Automation Stack
=======================

.. highlight:: console

Complete media automation solution using Docker containers for downloading, organizing, and managing media content.

⚠️ Prerequisites
================

**Docker Setup Required:**

Before deploying this stack, ensure Docker is properly configured in your Proxmox environment:

- `Proxmox VE Docker <https://community-scripts.github.io/ProxmoxVE/scripts?id=docker>`__ - Docker setup for LXC containers

This script will install Docker, Docker Compose, and Portainer for container management.

📋 Stack Overview
================

The media automation stack consists of:

- **Transmission**: BitTorrent client for downloading
- **Prowlarr**: Indexer manager and proxy
- **Radarr**: Movie collection manager
- **Sonarr**: TV series collection manager  
- **Bazarr**: Subtitle management
- **Jellyfin**: Media server (optional)

📚 Service References
====================

**Radarr (Movie Management)**:
- `Docker Hub - LinuxServer Radarr <https://hub.docker.com/r/linuxserver/radarr>`__
- `Guide to Radarr - Rapidseedbox <https://www.rapidseedbox.com/blog/guide-to-radarr>`__

**Transmission (Download Client)**:
- `Docker Hub - LinuxServer Transmission <https://hub.docker.com/r/linuxserver/transmission>`__

**Prowlarr (Indexer Manager)**:
- `Docker Hub - LinuxServer Prowlarr <https://hub.docker.com/r/linuxserver/prowlarr>`__
- `Prowlarr GitHub Repository <https://github.com/Prowlarr/Prowlarr>`__

**Bazarr (Subtitle Management)**:
- `Bazarr Setup Guide - Official Wiki <https://wiki.bazarr.media/Getting-Started/Setup-Guide/>`__

🚀 Quick Deployment
==================

**Option 1: Via Portainer (Recommended)**

1. **Access Portainer**:
   - Navigate to ``http://proxmox-ip:9000``
   - Login with your Portainer credentials

2. **Deploy Stack**:
   - Go to **Stacks** → **Add stack**
   - Name: ``media-automation``
   - Copy the following Docker Compose configuration:

   .. literalinclude:: ../configs/docker-compose/media-automation-stack.yml
      :language: yaml
      :caption: media-automation-stack.yml

   - Click **Deploy the stack**

**Option 2: Via Command Line**

1. **Deploy Stack**:

   .. code-block:: bash

      cd /opt/docker/media-stack
      docker-compose -f ../configs/docker-compose/media-automation-stack.yml up -d

2. **Verify Services**:

   .. code-block:: bash

      docker-compose ps

**Access Web Interfaces**:

- Transmission: ``http://proxmox-ip:9091``
- Prowlarr: ``http://proxmox-ip:9696``
- Radarr: ``http://proxmox-ip:7878``
- Bazarr: ``http://proxmox-ip:6767``

📁 Directory Structure
=====================

Required directories on Proxmox host:

.. code-block:: bash

   # Create user for media services
   adduser arr-stack --uid 1002 --disabled-password

   # Docker configuration directories (on container filesystem)
   mkdir -p /docker/{transmission/{data,watch},prowlarr/config,radarr/config,bazarr/config}
   
   # Docker configuration directories (from host PROXMOX for LXC containers)
   pct mount 23001
   # mounted CT 23001 in '/var/lib/lxc/23001/rootfs'
   chown -R 1002:1002 /var/lib/lxc/23001/rootfs/docker/
   pct unmount 23001
   
   # Media directories (on NAS via iSCSI mount)
   mkdir -p /mnt/nas-library/MULTIMEDIA/{movies,Downloads/{complete,incomplete}}
   
   # Set permissions
   chown -R 1002:1002 /docker/
   chown -R 1002:1002 /mnt/nas-library/MULTIMEDIA/

⚙️ Configuration Steps
=====================

Step 1: Configure Prowlarr
--------------------------

1. Access Prowlarr web interface
2. **Add Indexers**: Settings → Indexers → Add Indexer
   - Public: 1337x, The Pirate Bay, RARBG
   - Private: Add your private tracker credentials
3. **Connect to Radarr**: Settings → Apps → Add Application
   - Type: Radarr
   - Server: ``http://radarr:7878``
   - API Key: Copy from Radarr Settings → General

Step 2: Configure Radarr
------------------------

1. **Download Client**: Settings → Download Clients
   - Add Transmission: ``http://transmission:9091``
2. **Media Management**: Settings → Media Management
   - Root Folder: ``/movies``
   - Enable movie renaming
3. **Quality Profiles**: Configure preferred quality settings

Step 3: Configure Bazarr
------------------------

1. **Languages**: Settings → Languages
   - Add preferred subtitle languages
2. **Connect to Radarr**: Settings → Radarr
   - Address: ``http://radarr:7878``
   - API Key: Same as Prowlarr configuration
3. **Providers**: Settings → Providers
   - Enable OpenSubtitles, Subscene

🔄 Workflow Process
==================

1. **Add Movie** → Radarr web interface
2. **Search** → Prowlarr provides indexer sources
3. **Download** → Radarr sends to Transmission
4. **Process** → Radarr moves completed files
5. **Subtitles** → Bazarr downloads automatically
6. **Ready** → Media available for consumption

🔧 Maintenance Tasks
===================

Regular Maintenance
------------------

- **Weekly**: Check download queue and failed downloads
- **Monthly**: Update indexer configurations
- **Quarterly**: Review quality profiles and storage usage

Troubleshooting
--------------

- **Check logs**: ``docker-compose logs [service-name]``
- **Restart services**: ``docker-compose restart [service-name]``
- **Update containers**: ``docker-compose pull && docker-compose up -d``

📊 Monitoring
=============

Key metrics to monitor:

- Download speeds and queue status
- Storage usage and available space
- Service health and uptime
- Failed downloads and errors

**Configuration Files**:

- `media-automation-stack.yml <../configs/docker-compose/media-automation-stack.yml>`__ - Complete Docker Compose stack configuration

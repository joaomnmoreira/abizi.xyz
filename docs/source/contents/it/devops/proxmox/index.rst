======================
Proxmox Infrastructure
======================

.. highlight:: console

Complete Proxmox infrastructure documentation covering setup, services, and maintenance.

.. toctree::
   :maxdepth: 1
   :caption: Installation & Setup

   installation/baremetal-setup
   installation/post-install-config
   installation/storage-configuration

.. toctree::
   :maxdepth: 1
   :caption: Services

   services/media-automation-stack
   services/networking-services
   services/virtualization

.. toctree::
   :maxdepth: 1
   :caption: Maintenance

   maintenance/backup-procedures
   maintenance/monitoring-alerts
   maintenance/update-procedures
   maintenance/troubleshooting

Infrastructure Overview
=======================

**Current Setup**

- **Host**: Proxmox VE 8.x
- **Storage**: ZFS configuration
- **Networking**: Bridge configuration with VLANs

**Key Services**

- **Media Automation**: Radarr, Sonarr, Transmission, Prowlarr, Bazarr
- **Monitoring**: Prometheus, Grafana, Alertmanager
- **Networking**: pfSense, OpenWRT

Quick Start
===========

1. Follow :doc:`installation/baremetal-setup`
2. Run :doc:`installation/post-install-config`
3. Configure :doc:`installation/storage-configuration`
4. Deploy services from :doc:`services/media-automation-stack`
5. Setup :doc:`maintenance/backup-procedures`

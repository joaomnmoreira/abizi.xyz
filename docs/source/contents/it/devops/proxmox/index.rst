================
Proxmox Infrastructure
================

.. highlight:: console

This section documents the complete Proxmox infrastructure setup, configuration, and maintenance procedures.

📋 Quick Navigation
==================

Installation & Setup
--------------------

.. toctree::
   :maxdepth: 2

   installation/baremetal-setup
   installation/post-install-config
   installation/storage-configuration

Services & Applications
----------------------

.. toctree::
   :maxdepth: 2

   services/media-automation-stack
   services/networking-services
   services/monitoring-stack
   services/virtualization

Maintenance & Operations
-----------------------

.. toctree::
   :maxdepth: 2

   maintenance/backup-procedures
   maintenance/monitoring-alerts
   maintenance/update-procedures
   maintenance/troubleshooting

🔧 Configuration Files
=====================

All configuration files, scripts, and templates are organized in the ``configs/`` directory:

- **Docker Compose Stacks**: ``configs/docker-compose/``
- **Setup Scripts**: ``configs/scripts/``
- **Configuration Templates**: ``configs/templates/``
- **Automation Playbooks**: ``configs/ansible/``

📊 Infrastructure Overview
=========================

Current Proxmox Setup
---------------------

- **Host**: Proxmox VE 8.x
- **Storage**: ZFS configuration
- **Networking**: Bridge configuration with VLANs
- **Services**: Media automation, monitoring, networking

Key Services
-----------

- **Media Automation**: Radarr, Sonarr, Transmission, Prowlarr, Bazarr
- **Monitoring**: Prometheus, Grafana, Alertmanager
- **Networking**: pfSense, OpenWRT
- **Backup**: Automated backup solutions

🚀 Quick Start
==============

1. **Initial Setup**: Follow :doc:`installation/baremetal-setup`
2. **Post-Install**: Run :doc:`installation/post-install-config`
3. **Deploy Services**: Use configurations in ``configs/docker-compose/``
4. **Setup Monitoring**: Configure :doc:`services/monitoring-stack`
5. **Backup Setup**: Implement :doc:`maintenance/backup-procedures`

📝 Build Notes
==============

This documentation follows Infrastructure as Code principles:

- All configurations are version controlled
- Scripts ensure reproducible setups
- Documentation is procedure-driven
- Templates provide consistency

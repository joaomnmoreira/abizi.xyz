=======
Proxmox
=======

.. highlight:: console

Reference
---------

- `[Gruntwork] How to manage Terraform state <https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa>`__

Post Install Configuration
==========================

- `Post Install Configuration <https://www.youtube.com/watch?v=R0Zn0bdPwcw>`__

1. In 'Datacenter' - 'Storage', remove 'local-lvm';
2. In 'Node' - 'Shell', enter commands:

::
    
    lvremove /dev/pve/data
    lvresize -l +100%FREE /dev/pve/root
    resize2fs /dev/mapper/pve-root

3. In 'Datacenter' - 'Storage', edit 'local' and select all options in content;
4. Configure Repositories:
4.1. In 'Node' - 'Updates' - 'Repositories', select repository ENTERPRISE and PVE-ENTERPRISE and select DISABLE;
4.2. In. 'Node' - 'Updates' - 'Repositories', add repository 'No-Subscription';
4.3. In 'Node' - 'Updates', click REFRESH and then UPGRADE;
4.4. In GUI select REBOOT.

5. Disable 'Enterprise Pop-up':
5.1. Enter via SSH (putty):

::
    
    cd /usr/share/javascript/proxmox-widget-toolkit/
    cp proxmoxlib.js proxmoxlib.js.bak
    joe proxmoxlib.js

5.2. search for 'No valid subscription' and change to: void({ //Ext.Msg.show({
5.2.1. Save

::
    
    systemctl restart pveproxy.service

Storage Configuration
=====================

- `Storage Configuration <https://www.youtube.com/watch?v=HqOGeqT-SCA>`__

1. In 'Node' - 'Disks', wipe Storage Disks;
2. In 'Node' - 'Disks' - 'ZFS', create storage;
3. Create ZFS mountpoint in shell:

::
    
    zfs create ZFS01/Data01 -a mountpoint=zfsdata

3. Create Directory in ZFS Partition:
Select 'Datacenter' - 'Storage' - 'CREATE DIRECTORY'

::
    
    ID: ZFSData01
    Directory: /zfsdata
    Content: ALL SELECTED


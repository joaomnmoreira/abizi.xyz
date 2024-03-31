=======
Vagrant
=======

.. highlight:: console

Errors
======

`How to Resolve VirtualBox ‘Error in supR3HardenedWinReSpawn’? <https://appuals.com/supr3hardenedwinrespawn/>`__

Creating a box
==============

`Building a Vagrant Box from Start to Finish’? https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish/>`__

1. Requirements:
    
    Vagrant
    Oracle VirtualBox

2. Configure The Virtual Hardware:

    Create a new virtual machine with the following settings:

    - Name: vagrant-ubuntu64
    - Type: Linux
    - Version: Ubuntu64
    - Memory Size: 512MB (to taste)
    - New Virtual Disk: [Type: VMDK, Size: 40 GB]
    - Modify the hardware settings of the virtual machine for performance and because SSH needs port-forwarding enabled for the Vagrant user:

    - Disable audio
    - Disable USB
    - Ensure Network Adapter 1 is set to NAT
    - Add this port-forwarding rule: [Name: SSH, Protocol: TCP, Host IP: blank, Host Port: 2222, Guest IP: blank, Guest Port: 22]
    - Mount the Linux Distro ISO and boot up the server.

3. Install The Operating System:

    Setting up Ubuntu is simple. Follow the on-screen prompts, and when prompted to set up a user, set the user to vagrant and the password to vagrant.

4. Install The Operating System:

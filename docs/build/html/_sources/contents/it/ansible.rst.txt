==========
Ansible
==========

.. highlight:: console

AWX
===

Windows
=======

.. highlight:: powershell

Enable Windows Host
-------------------
- `Windows Setup <https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html>`__
- `Winrm <https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html>`__

To enable a windows host in order to be connected by ansible, run the following in PowerShell:
::

    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file -Verbose -EnableCredSSP

And, add user to be used as **ansible_user** within AWX, with administrative privileges.

AWX Configuration
-----------------
Configure ansible vars at HOST or GROUP level

.. code-block:: yaml

    ---
    ansible_user: <administrator user @ windows host>
    ansible_password: <administrator password @ windows host>
    ansible_connection: winrm
    ansible_winrm_transport: credssp
    ansible_winrm_server_cert_validation: ignore


Helpful Commands
----------------
Enumerate WinRM Listener
::

    winrm enumerate winrm/config/Listener

Current service configuration options
::

    winrm get winrm/config/Service
    winrm get winrm/config/Winrs

Enable CREDSSP
::

    Enable-WSManCredSSP -Role Server -Force
    Set-Item -Path "WSMan:\localhost\Service\Auth\CredSSP" -Value $true


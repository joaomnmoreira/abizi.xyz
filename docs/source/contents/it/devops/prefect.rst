=======
Prefect
=======

.. highlight:: console

Knowledge Base
--------------

- `How to run a Prefect 2 worker as a systemd service on Linux <https://discourse.prefect.io/t/how-to-run-a-prefect-2-worker-as-a-systemd-service-on-linux/1450>`__
- `How to deploy Prefect 2.0 flows to run as a local Process, Docker container or a Kubernetes job <https://discourse.prefect.io/t/how-to-deploy-prefect-2-0-flows-to-run-as-a-local-process-docker-container-or-a-kubernetes-job/1246>`__
- `Can I use .env files with Prefect 1.0 run configurations, e.g. using Python dotenv package? <https://discourse.prefect.io/t/can-i-use-env-files-with-prefect-1-0-run-configurations-e-g-using-python-dotenv-package/663>`__
- `Prefect recipes <https://github.com/PrefectHQ/prefect-recipes>`__

Steps
=====

- Install
- `Profile <https://docs.prefect.io/latest/concepts/settings/>`__
- Configure Storage S3 Block
- Configure Work Pools
- Systemd service Server
- Systemd service Agent


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


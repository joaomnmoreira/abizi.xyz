==============
MLOps Zoomcamp
==============

.. highlight:: console

Knowledge Base
--------------

- `How to run a Prefect 2 worker as a systemd service on Linux <https://discourse.prefect.io/t/how-to-run-a-prefect-2-worker-as-a-systemd-service-on-linux/1450>`__

Steps
=====

1. Create Virtual Environment:
::

    jmoreira@devbox-ubuntu2004:/opt/sportmultimedia/Repo/mlops$ python -m venv ../../Venvs/mlops

2. Install docker;
3. Install docker compose:
https://github.com/docker/compose/releases
::

    sudo wget sudo curl -L "https://github.com/docker/compose/releases/download/2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    docker compose version


4. Install Anaconda:
::

    wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh
    bash Anaconda3-2023.03-1-Linux-x86_64.sh





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



=============
Wireguard VPN
=============

.. highlight:: console

Commands
========

1. Install Raspberry Pi.

2. Install `wg-easy <https://github.com/wg-easy/wg-easy>`__.

3. Install Docker.

Basic installation (docker-compose)
-----------------------------------

Requirements
~~~~~~~~~~~~

1. Host you can manage (for example, a Raspberry Pi).
2. Domain name or public IP address.
3. Supported architecture (``x86_64``, ``arm64``, ``armv7``).
4. ``curl`` installed on the host.

Install Docker
~~~~~~~~~~~~~~

Follow the official Docker documentation for your distribution:
`https://docs.docker.com/engine/install/ <https://docs.docker.com/engine/install/>`__

Install wg-easy with docker-compose
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Create a directory for the configuration and compose file::

      sudo mkdir -p /etc/docker/containers/wg-easy

2. Download the official ``docker-compose.yml`` file::

      sudo curl -o /etc/docker/containers/wg-easy/docker-compose.yml \
        https://raw.githubusercontent.com/wg-easy/wg-easy/master/docker-compose.yml

   If your Raspberry Pi does not have direct internet access, download the file
   on another machine and copy it to the Pi, for example::

      # On your laptop/desktop (replace paths and hostname as needed)
      scp docker-compose.yml pi@<raspberry-pi-lan-ip>:/etc/docker/containers/wg-easy/docker-compose.yml

   For LAN-only or offline deployments, you can also configure the web UI to use
   plain HTTP (no TLS) on your internal network by uncommenting and adjusting
   the existing ``environment`` block in ``docker-compose.yml``::

      sudo sed -i \
        -e 's/^    #environment:/    environment:/' \
        -e 's/^    #  Optional:/    # Optional:/' \
        -e 's/^    #  - PORT=51821/      - PORT=51821/' \
        -e 's/^    #  - HOST=0.0.0.0/      - HOST=0.0.0.0/' \
        -e 's/^    #  - INSECURE=false/      - INSECURE=true/' \
        /etc/docker/containers/wg-easy/docker-compose.yml

3. Start wg-easy using ``docker compose``:

   .. code-block:: console

      cd /etc/docker/containers/wg-easy
      sudo docker compose up -d

   Whenever you change ``docker-compose.yml`` (for example, to adjust
   ``environment`` variables), recreate the container so the new
   configuration is applied::

      cd /etc/docker/containers/wg-easy
      sudo docker compose up -d --force-recreate

Update wg-easy
~~~~~~~~~~~~~~

To update wg-easy to the latest image::

      cd /etc/docker/containers/wg-easy
      sudo docker compose pull
      sudo docker compose up -d

Router configuration
--------------------

- Port forwarding:

  .. list-table:: Port Forwarding
     :widths: 20 20 20 20 20
     :header-rows: 1

     * - Service
       - Server LAN IP
       - Protocol
       - External Ports
       - Internal Ports
     * - VPN-Wireguard
       - xxx.xxx.xxx.xxx
       - UDP
       - xxxxx - xxxxx
       - 51820 - 51820

WireGuard client configuration
------------------------------

- Client app: ``<dynamic dns name>:xxxxx`` (configure external port).
- Client configuration: ``http://xxx.xxx.xxx.xxx:51821/``.

Auto update and reverse proxy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For auto updates and reverse proxy examples (Traefik, Caddy, or without a
reverse proxy), see the official wg-easy documentation:
`https://wg-easy.github.io/wg-easy/latest/examples/tutorials/basic-installation/ <https://wg-easy.github.io/wg-easy/latest/examples/tutorials/basic-installation/>`__
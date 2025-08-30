=============
Wireguard VPN
=============

.. highlight:: console

Commands
========

1. Install raspberry;
2. `wg-easy <https://github.com/wg-easy/wg-easy>`__;
2.1. Install Docker:

::
    
2.2. Run WireGuard Easy:

::
    docker run -d \
    --name=wg-easy \
    -e WG_HOST=<dynamic dns name>:xxxxx \
    -e PASSWORD=<wireguard UI password> \
    -v ~/.wg-easy:/etc/wireguard \
    -p 51820:51820/udp \
    -p 51821:51821/tcp \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
    --sysctl="net.ipv4.ip_forward=1" \
    --restart unless-stopped \
    ghcr.io/wg-easy/wg-easy

2.3. Web UI will be available on: http://<Server LAN IP>:51821
2.4. Configuration files: ~/.wg-easy

3. Router:
    - Port Forwarding:

.. list-table:: Port Forwarding
   :widths: 20 20 20 20
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

4. Wireguard Configuration:
    - Client APP: <dynamic dns name>:xxxxx (configure external port);
    - Client configuration: http://xxx.xxx.xxx.xxx:51821/.
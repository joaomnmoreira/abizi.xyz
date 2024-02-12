=============
Wireguard VPN
=============

.. highlight:: console

Commands
========

1. Install raspberry;
2. `wg-easy <https://github.com/wg-easy/wg-easy>`__;
3. Router:
    - Port Forwarding:


.. list-table:: Port Forwarding
   :widths: 20 20 20 20
   :header-rows: 1

   * - Service
     - Server IP
     - Protocol
     - External Ports
     - Internal Ports
   * - VPN-Wireguard
     - xxx.xxx.xxx.xxx
     - UDP
     - xxxxx - xxxxx
     - 51820 - 51820

4. Wireguard Configuration:
    - Client APP: <dns name>:xxxxx (configurel external port);
    - Client configuration: http://xxx.xxx.xxx.xxx:51821/.
Tunnelmole
===========

Tunnelmole is a tool that allows you to expose your local web servers to the internet. It's particularly useful for testing and sharing web applications during development. Here's how you can use it:

Installation
------------

Before you begin, make sure you have Node.js and npm (Node Package Manager) installed on your system.

To install LocalTunnel globally, open your terminal and run the following command:

.. code-block:: bash

    $ npm install -g tunnelmole

Usage
-----

Once Tunnelmole is installed, you can start using it with the following steps:

1. Start your local web server on a specific port. For example, to run a web server on port 3000, you might use:

.. code-block:: bash

    $ node server.js

2. Now, to expose this local server to the internet, execute the following command:

.. code-block:: bash

    $ tmole 3000

   Replace '3000' with the port your web server is running.

3. LocalTunnel does not support subdomains without a subscription plan.

For more options and advanced usage, you can refer to the official LocalTunnel documentation: `Tunnelmole Documentation <https://github.com/robbie-cahill/tunnelmole-client/>`_.

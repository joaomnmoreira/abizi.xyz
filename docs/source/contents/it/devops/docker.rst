======
Docker
======

.. highlight:: console

Commands
========

List all containers (only ID's):
::

    docker ps -a -q
    docker container ls --all --quiet

Delete all containers:
::

    docker rm -f $(docker ps -a -q)

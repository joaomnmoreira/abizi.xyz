========
RabbitMQ
========

.. highlight:: console

Quickstart
==========

Ensure broker/plugin installation:

::

    sudo apt-get install rabbitmq-server
    rabbitmq-plugins enable rabbitmq_management

Access dashboard:

    username: guest

    password: guest

::

    http://localhost:15672

Commands
--------

Prints enabled components (applications), TCP listeners, memory usage breakdown, alarms:

::

    sudo rabbitmq-diagnostics status

Checks if the local node is running and CLI tools can successfully authenticate with it

::

    sudo rabbitmq-diagnostics ping

Prints cluster membership information:

::

    sudo rabbitmq-diagnostics cluster_status

Prints effective node configuration:

::

    sudo rabbitmq-diagnostics environment

Add user:

::

    rabbitmqctl add_user '<username>' '<password>'

Add administrator tag to user:

::

    sudo rabbitmqctl set_user_tags <username> administrator

Delete guest user:

::

    rabbitmqctl delete_user guest

List users:

::

    rabbitmqctl list_users

List Permissions:

::

    rabbitmqctl list_permissions --vhost /
    rabbitmqctl list_permissions --vhost <vhost>

List vhosts:

::

    rabbitmqctl list_vhosts

Create vhost:

::

    rabbitmqctl add_vhost <vhost>

Set permissions in vhost for user:

::

    rabbitmqctl set_permissions -p <vhost> <username> ".*" ".*" ".*"

Export definitions:

::

    rabbitmqctl export_definitions /path/to/definitions.file.json


Number of tasks in a queue

::

    rabbitmqctl list_queues name messages messages_ready messages_unacknowledged

Number of workers currently consuming from a queue:

::

    rabbitmqctl list_queues name consumers

Amount of memory allocated to a queue:

::

    rabbitmqctl list_queues name memory



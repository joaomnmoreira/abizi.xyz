======
Django
======

.. highlight:: console

Quickstart
==========

  - https://www.django-rest-framework.org/tutorial/quickstart/

Quick Development Start
======================= 

::

    /opt/Repo$ git clone <project-name>.git
    /opt/Repo$ python -m venv ../Venvs/<project-name>

In VSCODE:

::

    F1 -> "Python: Select Interpreter"

Ctrl + J, to enter terminal.

Install Django and Django REST framework into the virtual environment

::

    pip install django djangorestframework

Create project and app:

::

    django-admin startproject <project-name> .
    django-admin startapp <app-name> 

Makemigrations and migrate:

::

    python manage.py makemigrations
    python manage.py migrate

Create superuser:

::

    python manage.py createsuperuser --email <email> --username <username>

Edit <app-name>/settings.py:

::

    ALLOWED_HOSTS = ['*']

Run development web server:

::

    python manage.py runserver 0:8000

Celery
======

Ensure broker/plugin installation:

::

    sudo apt-get install rabbitmq-server
    rabbitmq-plugins enable rabbitmq_management

In project virtual environment:

::

    pip install celery django_celery_beat django-celery-results

1. Add 'django_celery_results' and 'django_celery_beat' to your INSTALLED_APPS setting in settings.py.
2. Define a Celery instance in your project's __init__.py file:

.. code-block:: python
    :linenos:

    from celery import Celery
    from django.conf import settings

    app = Celery('my_project')

    # Load task modules from all registered Django app configs.
    app.autodiscover_tasks()

    # Configure the default settings for Celery
    app.conf.update(
        broker_url=settings.CELERY_BROKER_URL,
        result_backend=settings.CELERY_RESULT_BACKEND,
        timezone=settings.TIME_ZONE,
        task_track_started=True,
    )

3. In project settings.py:

::

    CELERY_BROKER_URL = 'amqp://localhost'
    CELERY_BROKER_URL="amqp://<user>:<password>@localhost:5672/<vhost>"
    CELERY_RESULT_BACKEND = 'django-db'

Commands
--------

Run celery worker:

::

    celery --app=<app-name> worker -l info --task-events --concurrency=1

Run celery beat:

::

    celery -A <app-name> beat -l info

Check registered celery tasks:

::

    celery -A <app-name> inspect registered

Purge tasks:

::

    celery --app=<app-name> call django_celery_beat.schedulers.DatabaseScheduler.purge

Call tasks from django commands:

::

    python manage.py call_celery_task celery_tasks.tasks.fetch_instagram_data
    python manage.py call_celery_task celery_tasks.tasks.fetch_instagram_posts
    python manage.py call_celery_task celery_tasks.tasks.fetch_instagram_post_metrics

Flower (http://localhost:5555)

::

    celery -A metrics --broker=amqp://localhost:5672// flower --broker_api=http://localhost:15672/api/
    celery -A metrics flower --broker=amqp://<user>:<password>@localhost:5672/ --broker_api=http://<user>:<password>@localhost:15672/api/
    celery -A vsports flower --logging=debug

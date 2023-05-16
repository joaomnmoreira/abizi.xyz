======
Django
======

.. highlight:: console

Quickstart
==========

  - https://www.django-rest-framework.org/tutorial/quickstart/

Develpoment
===========

::

    /opt/Repo$ git clone <project-name>.git
    /opt/Repo$ python -m venv ../Venvs/<project-name>

In VSCODE:

::

    F1 -> "Python: Select Interpreter"

Ctrl + J, to enter terminal:

::

    pip install django djangorestframework

Create project:

::

    django-admin startproject <project-name> . && cd <project-name> 

Create app:

::

    django-admin startapp <app-name> && cd ..

Migrate:

::

    python manage.py migrate

Create superuser:

::

    python manage.py createsuperuser --email <email> --username <username>

Edit <app-name>/settings.py:

::

    ALLOWED_HOSTS = ['*']

Run development server:

::

    python manage.py runserver 0:8000
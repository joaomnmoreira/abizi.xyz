Git: Sync a Local Directory with a Cloud Repository
===================================================

This guide explains how to upload a local code directory to a new repository
on **GitHub**, **GitLab**, or a similar service.

Step 1: Create a Repository on the Cloud
----------------------------------------

1. **Log in** to your chosen platform (e.g., GitHub).
2. **Create a new, empty repository**. Give it a name.
3. **Important**: Do **not** initialize it with a ``README``, ``.gitignore``,
   or ``LICENSE`` file. This ensures a clean history for your first upload.
4. **Copy the HTTPS URL** provided. It will look like this:

   .. code-block:: text

      https://github.com/your-username/your-repository-name.git

Step 2: Prepare Your Local Directory
------------------------------------

Open your terminal or command prompt and navigate to your project's folder.

1. Navigate to your folder:

   .. code-block:: bash

      cd /path/to/your/project

2. Initialize Git:

   .. code-block:: bash

      git init -b main

3. Stage all files for the first commit:

   .. code-block:: bash

      git add .

4. Save your changes by making a commit:

   .. code-block:: bash

      git commit -m "Initial commit"

Step 3: Connect and Push to the Cloud
-------------------------------------

Now, link your local directory to the cloud repository and upload your code.

1. Add the remote repository URL (replace with your own URL):

   .. code-block:: bash

      git remote add origin https://github.com/your-username/your-repository-name.git

2. Push (upload) your code:

   .. code-block:: bash

      git push -u origin main

   You may be prompted to enter your username and password or a Personal
   Access Token (PAT).

Daily Workflow: Keep in Sync
----------------------------

To send your latest local changes to the cloud:

.. code-block:: bash

   git add .
   git commit -m "Describe your changes here"
   git push

To receive the latest changes from the cloud:

.. code-block:: bash

   git pull

=========
Terraform
=========

.. highlight:: console

Reference
---------

- `[Gruntwork] How to manage Terraform state <https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa>`__
- `Terraform S3 Backend <https://github.com/MattMorgis/digitalocean-spaces-terraform-backend>`__
- `Sharing data between terraform configurations <https://jamesmckay.net/2016/09/sharing-data-between-terraform-configurations/>`__

Commands
--------

- Terraform init

::
    
    terraform init -reconfigure -get-plugins=true -backend-config=access_key=$SPACES_ACCESS_TOKEN -backend-config=secret_key=$SPACES_SECRET_KEY
    terraform init -upgrade


- Terraform destroy

::
    
    terraform taint digitalocean_droplet.project-droplet
    terraform taint digitalocean_droplet.project-droplet[0]
    terraform taint digitalocean_database_db.database-name

- Terraform plan

::
    
    terraform plan -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" -out=tfplan -input=false
    terraform plan -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" -var "spaces_token=${SPACES_ACCESS_TOKEN}" -var "spaces_secret=${SPACES_SECRET_KEY}" -out=tfplan -input=false

- Terraform apply

::
    
    terraform apply -input=false tfplan

- View outputs

::
    
    terraform output

.. _s3backend-anchor:

Configure S3 backend
====================

.. code-block:: terraform
    :linenos:

    terraform {
        
      backend "s3" {
      endpoint   = "https://<s3_endpoint>"
      bucket     = "<s3_bucket_name>"

      # whatever directory/file name (*.tfstate) structure desired
      key        = "terraform/global/tags/terraform.tfstate"

      skip_credentials_validation = true        # Needed for non AWS S3
      skip_metadata_api_check     = true        # Needed for non AWS S3
      region                      = "eu-west-2" # Needed for non AWS S3. Basically this gets ignored, but field is needed
      }
    }

Acess S3 remote state
=====================

In exporting working directory :
    1. :ref:`Configure S3 backend <s3backend-anchor>` for respective working directory;
    2. Configure resource and output desired attribute to be used in other workflow:

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    resource "digitalocean_tag" "env_dev" {
      name = "development"
    }    

.. code-block:: terraform
    :linenos:
    :caption: output.tf

    output "env_dev_id" {
      value = "${digitalocean_tag.env_dev.id}"
      description = "Tag ENVIRONMENT Development"
    }

In importing working directory:
    1. :ref:`Configure S3 backend <s3backend-anchor>` for respective working directory;
    2. Requirements:
        - `boto <https://boto3.amazonaws.com/v1/documentation/api/latest/index.html>`__
        - Configured profile with access_key and secret;

    2. Configure "terraform_remote_state" resource to access remote working directory state. In resource reference get output exported field from "terraform_remote_state":

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    data "terraform_remote_state" "tags" {
        backend = "s3"
        config = {
        endpoint   = "https://<s3_endpoint>"
        bucket     = "<s3_bucket_name>"
        # Path to the file we wnat to retrieve data
        key      = "terraform/global/tags/terraform.tfstate"

        shared_credentials_file = "/etc/boto.cfg"
        profile  = "digitalocean"

        skip_credentials_validation = true        # Needed for non AWS S3
        skip_metadata_api_check     = true        # Needed for non AWS S3
        region                      = "eu-west-2" # Needed for non AWS S3. Basically this gets ignored, but field is needed
        }
    }

    resource "digitalocean_droplet" "project-droplet" {
      ...
      tags = ["${data.terraform_remote_state.tags.outputs.env_prod_id}"]
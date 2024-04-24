=========
Terraform
=========

.. highlight:: console

Reference
---------

- `[Gruntwork] How to manage Terraform state <https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa>`__
- `Terraform S3 Backend <https://github.com/MattMorgis/digitalocean-spaces-terraform-backend>`__
- `Sharing data between terraform configurations <https://jamesmckay.net/2016/09/sharing-data-between-terraform-configurations/>`__
- `Terraform import <https://www.terraform.io/docs/import/index.html>`__

Install
-------

- `Terraform installation <https://developer.hashicorp.com/terraform/install>`__
- `Terraform releases notes <https://github.com/hashicorp/terraform/releases>`__
- `Terraform providers <https://registry.terraform.io/browse/providers>`__

::
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    
- Know which versions are available for a certain package

::
    apt list --all-versions terraform

- Install a specific version of a package

::
    sudo apt install terraform=1.7.5-1


- `DigitalOcean Provider <https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs>`__

Commands
--------

- Terraform init

::
    
    terraform init -reconfigure -get=true -backend-config=access_key=$SPACES_ACCESS_TOKEN -backend-config=secret_key=$SPACES_SECRET_KEY
    terraform init -upgrade -reconfigure -get=true -backend-config=access_key=$SPACES_ACCESS_TOKEN -backend-config=secret_key=$SPACES_SECRET_KEY
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

- Know providers dependencies

::
    terraform providers

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

Or, recent terraform versions '>=v.1.6.6':

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    terraform {
      backend "s3" {
        endpoints = {
          s3 = "https://<s3_endpoint>"
        }
        
        bucket   = "<s3_bucket_name>"

        # whatever directory/file name (*.tfstate) structure desired
        key = "terraform/global/tags/terraform.tfstate"

        skip_credentials_validation = true        # Needed for non AWS S3
        skip_requesting_account_id  = true        # Needed for non AWS S3
        skip_metadata_api_check     = true        # Needed for non AWS S3
        skip_s3_checksum            = true        # Needed for non AWS S3 [https://github.com/hashicorp/terraform/issues/34086]
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
        # Path to the file we want to retrieve data
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

Or, recent terraform versions '>=v.1.6.6':

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    data "terraform_remote_state" "tags" {
    backend = "s3"
    config = {
        endpoints = {
        s3 = lookup(var.s3, "ENDPOINT")
        }

        bucket   = lookup(var.s3, "BUCKET")

        # Path to the file we want to retrieve data
        key      = "terraform/eco-b24/webb24/terraform.tfstate"

        shared_credentials_files = [lookup(var.s3, "CRED_FILE")]
        profile                  = lookup(var.s3, "PROFILE")

        skip_credentials_validation = true        # Needed for non AWS S3
        skip_requesting_account_id  = true        # Needed for non AWS S3
        skip_metadata_api_check     = true        # Needed for non AWS S3
        region                      = "eu-west-2" # Needed for non AWS S3. Basically this gets ignored, but field is needed
        }
    }

Import Resources
================

The current implementation of Terraform import can only import resources into the state. It does not generate configuration. A future version of Terraform will also generate configuration.

Because of this, prior to running terraform import it is necessary to write manually a resource configuration block for the resource, to which the imported object will be mapped.

1. Manually create a resource:

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    resource "digitalocean_domain" "default" {
        #
    }

The name "default" here is local to the module where it is declared and is chosen by the configuration author. This is distinct from any ID issued by the remote system, which may change over time while the resource name remains constant.

2a. Terraform import (domain example):

.. code-block:: bash

    terraform import -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" digitalocean_domain.default sportmultimedia.pt

2b. Terraform import (firewall example):

Firewall ID obtained via:

.. code-block:: bash

    doctl compute firewall list

.. code-block:: bash

    terraform import -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" digitalocean_firewall.project-firewall 9b3c63d3-86bb-4187-b9f9-d777b80f4674


2c. Terraform import (droplet example):

Firewall ID obtained via:

.. code-block:: bash

    doctl compute droplet list | grep <droplet name>

.. code-block:: bash

    terraform import -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" digitalocean_droplet.project-droplet 116576246

3. Edit resource to match:

.. code-block:: terraform
    :linenos:
    :caption: main.tf

    resource "digitalocean_domain" "default" {
        name = "sportmultimedia.pt"
    }

 
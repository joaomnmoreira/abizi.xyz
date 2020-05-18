=========
Terraform
=========

.. highlight:: console

Reference
=========

- `[Gruntwork] How to manage Terraform state <https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa>`__
- `Terraform S3 Backend <https://github.com/MattMorgis/digitalocean-spaces-terraform-backend>`__
- `Sharing data between terraform configurations <https://jamesmckay.net/2016/09/sharing-data-between-terraform-configurations/>`__

Commands
========

    - Terraform init

::
    
    terraform init -reconfigure -get-plugins=true -backend-config=access_key=$SPACES_ACCESS_TOKEN -backend-config=secret_key=$SPACES_SECRET_KEY

    - Terraform plan

::
    
    terraform plan -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" -out=tfplan -input=false
    terraform plan -var "do_token=${DIGITALOCEAN_ACCESS_TOKEN}" -var "spaces_token=${SPACES_ACCESS_TOKEN}" -var "spaces_secret=${SPACES_SECRET_KEY}" -out=tfplan -input=false

    - Terraform apply

::
    
    terraform apply -input=false tfplan


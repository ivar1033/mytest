
# My Test Deployment ( Assignemnt Number 2 )

Steps to run the automation

* Make sure Terraform and Ansible is installed in the system if not follow steps below.

  *    Run below commands to install terraform and ansible
       
      sudo apt update
      sudo apt install -y python3-pip
      sudo pip3 install ansible

       Install Terraform from the link 
      https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

    * Add below lines to ansible.cfg file
      
      [defaults]

      host_key_checking = False

    * Make sure to keep key.pem file in the same directory as automation 

*    Run below commands to install start automation

    terraform init
    terraform plan 
    terraform apply
 


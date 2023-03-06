# Configure the AWS provider
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = ""   #provide key
  secret_key = ""   #provide key
}

# Create a security group for the DB instance
resource "aws_security_group" "mediawikidbsg" {
  name_prefix = "Mediawikidb"
  description = "Mediawiki security group for DB"
  vpc_id      = "vpc-05f7d56fdde082ce6"


ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
}

# Create a security group for the EC2 instance
resource "aws_security_group" "mediawikisg" {
  name_prefix = "Mediawiki"
  description = "Mediawiki security group for EC2 instance"
  vpc_id      = "vpc-05f7d56fdde082ce6"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the MySQL database instance
resource "aws_db_instance" "mediawikidb" {
  identifier              = "mediawiki-db"
  engine                  = "mysql"
  instance_class          = "db.t2.micro"
  db_name                 = "wikidatabase"
  username                = "wiki"
  password                = "password123"
  allocated_storage       = 10
  storage_type            = "gp2"
  vpc_security_group_ids  = [aws_security_group.mediawikidbsg.id]
  skip_final_snapshot     = true
  backup_retention_period = 0
}

# Create an EC2 instance that depends on the MySQL database instance
resource "aws_instance" "Mediawiki" {
  ami                    = "ami-0c9978668f8d55984"
  instance_type          = "t2.micro"
  key_name               = "mykey"  #EC2 Key
  vpc_security_group_ids = [aws_security_group.mediawikisg.id]
  depends_on = [aws_db_instance.mediawikidb]

  tags = {
    Name = "Mediawiki EC2 Instance"
  }
}

resource "null_resource" "Mediawiki-SSh-check" {
  provisioner "remote-exec" {
    connection {
      host        = aws_instance.Mediawiki.public_dns
      user        = "ec2-user"
      private_key = file("mykey.pem")   #EC2 Key
    }

    inline = ["echo 'connected!'"]
  }

  provisioner "local-exec" {
    command = "echo '${aws_instance.Mediawiki.public_ip}' > hosts.ini; chmod 600 mykey.pem"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i hosts.ini mediawiki.yml -u ec2-user --private-key mykey.pem -vvv"
  }
}
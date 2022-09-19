provider "aws" {
  region = local.region
  shared_credentials_file = "/Users/ramababu.bendalam/.aws/credentials"
  profile                 = "experiment"
}

locals {
  name   = "ec2-kubernetes"
  region = "eu-west-1"

  user_data = <<-EOT
  #!/bin/bash
  set -e
  yum update -y
  yum install -y git
  amazon-linux-extras install -y docker
  usermod -a -G docker ec2-user
  service docker start
  curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
  chmod +x /usr/bin/docker-compose
  curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv -f kubectl /usr/bin/kubectl
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube
  mv -f minikube /usr/bin/minikube
  export MINIKUBE_HOME=/root/.minikube
  export KUBECONFIG=/root/.kube/config
  touch /tmp/minikube.txt
  minikube start --vm-driver=docker --force > /tmp/minikube.txt
  EOT

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

################################################################################
# EC2 Module
################################################################################

module "ec2_complete" {
  source = "./module/"

  name = local.name

  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.large"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  user_data_base64            = base64encode(local.user_data)
  key_name = "ssh-dev-ireland"
  ssh_key_file_location = "/Users/ramababu.bendalam/ssh-dev-ireland.pem"
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "dev-block"
      }
    },
  ]

  tags = local.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  tags = local.tags
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh access"
      cidr_blocks = "80.208.218.141/32"
    },
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = "service port acccess"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

resource "aws_kms_key" "this" {
}


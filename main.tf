
# terraform.tf ---------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

# providers.tf --------------------------
provider "aws" {
  region = var.region
}

# variable.tf 
variable "region" {
  type    = string
  default = "ap-south-1"
}
variable "environment" {
  type    = string
  default = "sample-project"
}

variable "root_block_config" {
  type = object({
    v_size = string
    v_type = string
  })
  default = {
    v_size = "20"
    v_type = "gp3"
  }
}

# variable "ec2_config_map" {
#   type = map(object({
#     ami_id        = string
#     instance_type = string
#   }))
# }

# variable "subnet_mapping" {
#   type = map(number)
#   default = {
#     "ubuntu"       = 0
#     "amazon-linux" = 0
#   }
# }

variable "ec2_instance_list" {

  type = list(object({
    name          = string
    ami_id        = string
    instance_type = string
    subnet_index  = number
  }))
}

# vpc.tf -----------------------------------
module "my_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = "${var.environment}-vpc"
  cidr                    = "10.0.0.0/16"
  azs                     = ["ap-south-1a"]
  public_subnets          = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets         = ["10.0.2.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_vpn_gateway      = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-vpc"
  }
}

# security_group.tf ---------------------
module "my_sg" {
  source = "terraform-aws-modules/securit-group/aws"

  description = "This is SG for sample-project"
  vpc_id      = module.my_vpc.vpc_id

  ingress_with_cidr_block = [
    {
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-SG"
  }
}

# key_pair.tf --------------------

resource "aws_key_pair" "my_key" {
  key_name   = "my-secret-key"
  public_key = file("my-secret-key.pub")

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-key-pair"
  }

}

# ec2.tf ------------------------------
resource "aws_instance" "my_server" {

  for_each      = { for idx, inst in var.ec2_instance_list : inst.name => inst }
  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  key_name      = aws_key_pair.my_key.key_name

  vpc_security_group_ids = [module.my_sg.security_group_id]
  subnet_id              = module.my_vpc.public_subnets[each.value.subnet_index]

  user_data = file("install_apache.sh")

  root_block_device {
    volume_size           = var.root_block_config.v_size
    volume_type           = var.root_block_config.v_type
    delete_on_termination = true
  }

  tags = {
    Environment     = var.environment
    Name            = "${var.environment}-instance-${each.key}"
    created_by_user = "Aditya Bahuguna"
  }
}

# output.tf --------------------------------

output "instance_details" {
  value = {
    for i in aws_instance.my_server : i.tags["Name"] => {
      instance_id       = i.id
      ami_id            = i.ami
      instance_type     = i.instance_type
      public_ip         = i.public_ip
      public_dns        = i.public_dns
      private_ip        = i.private_ip
      key_name          = i.key_name
      volume_size       = var.root_block_config.v_size
      volume_type       = var.root_block_config.v_type
      availability_zone = i.availability_zone
      environment       = i.tags["Environment"]
      created_by_user   = i.tags["created_by_user"]
    }
  }
}

output "vpc_details" {
  value = {
    vpc_name        = module.my_vpc.name
    vpc_id          = module.my_vpc.vpc_id
    azs             = module.my_vpc.azs
    private_subnets = module.my_vpc.private_subnets
    public_subnets  = module.my_vpc.public_subnets
  }
}

output "sg_details" {
  value = {
    security_group_id = module.my_sg.security_group_id
  }
}
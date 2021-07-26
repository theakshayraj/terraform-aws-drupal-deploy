locals {
  name = "group-vpc"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = local.name
  cidr = var.cidr_vpc

  azs             = var.az_vpc
  public_subnets  = var.pub_sub_vpc
  private_subnets = var.pri_sub_vpc

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "security_group_asg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"

  name   = "security-group_asg"
  vpc_id = module.vpc.vpc_id
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "all"
      description = "Open internet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_with_cidr_blocks = [

    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "110.235.219.73/32"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "110.235.219.73/32"
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "NFS"
      cidr_blocks = "110.235.219.73/32"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "ALB Port Open in ASG"
      cidr_blocks = "10.99.0.0/18"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "110.235.219.73/32"
    },

    {
    description      = "Custom TCP"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = "0.0.0.0/0"
    },

    {
    description      = "Custom TCP"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = "0.0.0.0/0"
    },

   {
    description      = "Custom TCP"
    from_port        = 9093
    to_port          = 9093
    protocol         = "tcp"
    cidr_blocks      = "0.0.0.0/0"
   },


   {
    description      = "Custom TCP"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = "0.0.0.0/0"
   }
  ]
}

module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.0.0"
  name   = "security-group_rds"
  vpc_id = module.vpc.vpc_id
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "all"
      description = "Open internet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "All TCP"
      cidr_blocks = "110.235.219.73/32"
    }
  ]

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "Added ASG SG"
      source_security_group_id = module.security_group_asg.security_group_id
    }
  ]

  number_of_computed_ingress_with_source_security_group_id = 1
}

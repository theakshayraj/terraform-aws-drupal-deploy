locals {
  name = "group-asg"
}

# generate key-pair for launch template
resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "instance-key"
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.dev_key.private_key_pem}' > ./instance-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 ./instance-key.pem"
  }
}

module "aws_autoscaling_group" {

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.1.0"

  # Autoscaling group
  name = "group-testing"

  min_size                  = var.min_size_asg
  max_size                  = var.max_size_asg
  desired_capacity          = var.des_cap_asg
  wait_for_capacity_timeout = var.cap_timeout
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnet_asg
  security_groups           = [var.sec_group_asg]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
  }

  # Launch template
  lt_name     = var.temp_name
  description = var.temp_desc
  use_lt      = true
  create_lt   = true

  image_id      = var.img_id
  instance_type = var.ami_type

  key_name      = "instance-key"
  user_data_base64 = base64encode(templatefile("${path.module}/userdata.sh", {
    rds_endpt = var.rds_point
  }))

  target_group_arns = var.target_gp

  health_check_grace_period = 300

  tags = [
    {
      key                 = "Project"
      value               = "terraform_drupal"
      propagate_at_launch = "true"
    },
    {
      key                 = "Name"
      value               = "terraform_asg_cluster"
      propagate_at_launch = "true"
    },
    {
      key                 = "BU"
      value               = "group-testing"
      propagate_at_launch = "true"
    },
    {
      key                 = "Owner"
      value               = "akshay.raj@tothenew.com"
      propagate_at_launch = "true"
    },
    {
      key                 = "Purpose"
      value               = "group project"
      propagate_at_launch = "true"
    }
  ]
}
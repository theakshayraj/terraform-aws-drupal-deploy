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

resource "aws_iam_role" "drupal_access_role" {
  name               = "drupal_access_role"
  assume_role_policy = file("./modules/asg/policies/assume_role_policy.json")
}

resource "aws_iam_instance_profile" "drupal-grp_profile" {
  name = "drupal-grp_profile"
  role = aws_iam_role.drupal_access_role.name
}

# resource "aws_iam_policy" "cloudwatchagentserver-policy" {
#   name        = "cloudwatchagentserver-policy"
#   description = "cloudwatch agent server policy"
#   policy      = file("./modules/asg/policies/CloudwatchAgentServerPolicy.json")
# }

# resource "aws_iam_policy_attachment" "cloudwatchagentserver-attach" {
#   name       = "cloudwatchagentserver-attachment"
#   roles      = [aws_iam_role.drupal_access_role.name]
#   policy_arn = aws_iam_policy.cloudwatchagentserver-policy.arn
# }

data "aws_iam_policy" "CloudWatchAgentPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy_attachment" "cloudwatch-agent-server-policy-attach" {
  name =  "cloudwatch-agent-server-policy-attach"
  roles       = [aws_iam_role.drupal_access_role.name]
  policy_arn = data.aws_iam_policy.CloudWatchAgentPolicy.arn
}

resource "aws_iam_policy" "cw-s3-policy" {
  name        = "cw-s3-policy"
  description = "cloudwatch agent s3 server policy"
  policy      = file("./modules/asg/policies/s3-policy.json")
}

resource "aws_iam_policy_attachment" "cw-s3-attach" {
  name       = "cw-s3-attachment"
  roles      = [aws_iam_role.drupal_access_role.name]
  policy_arn = aws_iam_policy.cw-s3-policy.arn
}


module "aws_autoscaling_group" {
  #source = "git@github.com:terraform-aws-modules/terraform-aws-autoscaling.git?ref=v4.1.0"

  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.1.0"

  # Autoscaling group
  name = "group-testing"

  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 2
  wait_for_capacity_timeout = "5m"
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
  lt_name     = "foobar"
  description = "Complete launch template example"
  use_lt      = true
  create_lt   = true

  image_id      = var.img_id
  instance_type = "t3.large"
  key_name      = "instance-key"
  iam_instance_profile_arn = aws_iam_instance_profile.drupal-grp_profile.arn
  #user_data_base64 = base64encode(local.user_data)
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

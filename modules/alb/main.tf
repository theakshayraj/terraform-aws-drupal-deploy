module "alb" {
  #source = "git@github.com:terraform-aws-modules/terraform-aws-alb.git?ref=v6.0.0"

  source  = "terraform-aws-modules/alb/aws"
  version = "6.0.0"
  name = "group-alb"

  load_balancer_type = "application"

  vpc_id          = var.vpc_alb
  subnets         = var.subnet_alb
  security_groups = [var.sec_group_alb]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = "i-0123456789abcdefg"
          port = 80
        },
        {
          target_id = "i-a1b2c3d4e5f6g7h8i"
          port = 8080
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}

  tags = {
    Project = "terraform_drupal"
    Name    = "terraform_asg_cluster"
    BU      = "group-testing"
    Owner   = "akshay.raj@tothenew.com"
    Purpose = "group project"
  }
}

output "tg" {
  value = module.alb.target_group_arns
}

output "alb_dns" {
  value = module.alb.lb_dns_name
}

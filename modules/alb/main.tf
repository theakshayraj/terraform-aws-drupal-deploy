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
      #name             = ""
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 110
        path                = "/drupal"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 100
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type        = "forward"
    }
  ]

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
  
output "dns" {
  value = module.alb.lb_dns_name
}

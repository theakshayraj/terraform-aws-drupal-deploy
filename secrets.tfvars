db_user = "drupaladmin"
db_pass = "redhat22"

region = "us-east-1"
autoscale_minimum_size = 1
autoscale_maximum_size = 5
autoscale_desired_cap  = 2
autoscale_capacity_time = "10m"
template_name = "Drupal"
template_desc = "Template for drupal installation"
ami_id = "ami-0dc2d3e4c0f9ebd18"
ami_type = "t2.micro"

vpc_cidr = "10.99.0.0/18"
vpc_azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_public_subnets = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
vpc_private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

rds_identifier = "rds"
rds_engine = "mysql"
rds_engine_ver = "5.7"
rds_instance_class = "db.t2.micro"

db_allocated_storage = 50
db_max_allocated_storage = 100
db_port = 3306
db_parameter_group = "default.mysql5.7"
db_mastername = "mydb_source"
db_maintenance_window = "Sun:05:00-Sun:06:00"
db_backup_window = "09:46-10:16"

locals {
  name = var.identifier_rds
  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

module "terraform-aws-rds-source" {

  source  = "terraform-aws-modules/rds/aws"
  version = "3.0.0"

  identifier = "${local.name}-master"

  engine         = var.engine_rds
  engine_version = var.engine_ver_rds
  instance_class = var.instance_class_rds

  allocated_storage     = var.aloc_strg
  max_allocated_storage = var.max_aloc_strg

  name     = var.master_db_name
  username = var.db_username
  password = var.db_password
  port     = var.port_db

  parameter_group_name      = var.family
  create_db_parameter_group = false
  create_db_option_group    = false

  maintenance_window = var.maintenance
  backup_window      = var.backup

  backup_retention_period = 1
  skip_final_snapshot     = true

  subnet_ids             = var.subnet_rds
  vpc_security_group_ids = [var.sec_group_rds]
}

output "rds_endpoint" {
  value = module.terraform-aws-rds-source.db_instance_endpoint
}

module "terraform-aws-rds-read" {

  source  = "terraform-aws-modules/rds/aws"
  version = "3.0.0"

  identifier = "${local.name}-replica"

  engine         = var.engine_rds
  engine_version = var.engine_ver_rds
  instance_class = var.instance_class_rds

  allocated_storage     = var.aloc_strg
  max_allocated_storage = var.max_aloc_strg

  # Username and password should not be set for replicas
  #name     = "mydb_read"
  username = null
  password = null
  port     = var.port_db

  parameter_group_name      = var.family
  create_db_parameter_group = false
  create_db_option_group    = false

  maintenance_window = var.maintenance
  backup_window      = var.backup

  #for read replica
  replicate_source_db = module.terraform-aws-rds-source.db_instance_id

  backup_retention_period = 1
  skip_final_snapshot     = true

  create_db_subnet_group = false
}

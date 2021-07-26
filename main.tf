module "db" {
  source        = "./modules/db/"
  vpc_asg       = module.network.vpc_id_all
  sec_group_rds = module.network.security_group_id_rds
  subnet_rds    = module.network.public_sn_asg
  db_username   = var.db_user
  db_password   = var.db_pass
}

module "asg" {
  source        = "./modules/asg/"
  subnet_asg    = module.network.public_sn_asg
  sec_group_asg = module.network.security_group_id_asg
  rds_point     = module.db.rds_endpoint
  depends_on    = [module.db.rds_endpoint]
  target_gp     = module.alb.tg
  min_size_asg  = var.autoscale_minimum_size
  max_size_asg  = var.autoscale_maximum_size
  des_cap_asg   = var.autoscale_desired_cap
  cap_timeout   = var.autoscale_capacity_time
  temp_name     = var.template_name
  temp_desc     = var.template_desc
  img_id        = var.ami_id
  ami_type      = var.ami_type
}

module "network" {
  source = "./modules/network/"
}

module "alb" {
  source        = "./modules/alb/"
  vpc_alb       = module.network.vpc_id_all
  sec_group_alb = module.network.security_group_id_asg
  subnet_alb    = module.network.public_sn_asg
}

module "monitoring" {
  source = "./modules/monitoring/"
  subnet_monitoring_instance = module.network.public_sn_asg[0]
  vpc_security_group_monitoring = module.network.security_group_id_asg
}

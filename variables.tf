variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "access_key" {
  sensitive = true
}
variable "secret_key" {
  sensitive = true
}

variable "autoscale_minimum_size" {
  default = 1
  type = number
}

variable "autoscale_maximum_size" {
  default = 5
  type = number
}

variable "autoscale_desired_cap" {
  default = 2
  type = number
}

variable "autoscale_capacity_time" {
  default = "5m"
  type = string
}

variable "template_name" {
  default = "template"
  type = string
}

variable "template_desc" {
  default = "Description goes here"
  type = string
}

variable "ami_id" {
  type = string
  default = "ami-0dc2d3e4c0f9ebd18"
}

variable "ami_type" {
  default = "t2.micro"
  type = string
}

variable "db_user" {
  type = string
  sensitive = true
}

variable "db_pass" {
  type = string
  sensitive = true
}

variable "vpc_cidr" {
  type = string
  default = "10.99.0.0/18"
}

variable "vpc_azs" {
  type = list
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_public_subnets" {
  type = list
  default = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
}

variable "vpc_private_subnets" {
  type = list
  default = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
}

variable "rds_identifier" {
  type = string
  default = "rds"
}

variable "rds_engine" {
  type = string
  default = "mysql"
}

variable "rds_engine_ver" {
  type = string
  default = "5.7"
}

variable "rds_instance_class" {
  type = string
  default = "db.t2.micro"
}

variable "db_allocated_storage" {
  type = number
  default = 50
}

variable "db_max_allocated_storage" {
  type = number
  default = 100
}

variable "db_port" {
  type = number
  default = 3306
}

variable "db_parameter_group" {
  type = string
  default = "default.mysql5.7"
}

variable "db_mastername" {
  type = string
  default = "mydb_source"
}

variable "db_maintenance_window" {
  type = string
  default = "Sun:05:00-Sun:06:00"
}

variable "db_backup_window" {
  type = string
  default = "09:46-10:16"
}

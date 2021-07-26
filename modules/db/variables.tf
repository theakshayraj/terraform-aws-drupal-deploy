variable "vpc_asg" {

}

variable "sec_group_rds" {

}

variable "subnet_rds" {

}

variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "access_key"{
  sensitive = true
}
variable "secret_key" {
  sensitive = true
}

variable "autoscale_minimum_size" {
  type = string
}

variable "autoscale_maximum_size" {
  type = string
}

variable "autoscale_desired_cap" {
  type = string
}

variable "autoscale_capacity_time" {
  type = string
}

variable "template_name" {
  type = string
}

variable "template_desc" {
  type = string
}

variable "ami_id" {
  type = string
  default = "ami-0dc2d3e4c0f9ebd18"
}

variable "ami_type" {
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

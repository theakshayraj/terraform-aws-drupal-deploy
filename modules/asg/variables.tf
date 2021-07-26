variable "rds_point" {

}

variable "sec_group_asg" {

}

variable "subnet_asg" {

}

variable "target_gp" {

}


variable "min_size_asg" {
	default = "1"
}

variable "max_size_asg" {
	default = "5"
}

variable "des_cap_asg" {
	default = "2"
}

variable "cap_timeout" {
	default = "5m"
}

variable "temp_name" {
	default = "template"
}

variable "temp_desc" {
	default = "Description goes here"
}

variable "img_id" {
	type = string
}

variable "ami_type" {
	default = "t2.micro"
}

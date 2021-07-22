resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "monitoring-key"
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" {    
    command = "echo '${tls_private_key.dev_key.private_key_pem}' > ./monitoring-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 ./monitoring-key.pem"
  }
}
resource "aws_security_group" "allow_ports" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Custom TCP"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Custom TCP"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Custom TCP"
    from_port        = 9093
    to_port          = 9093
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "Custom TCP"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_ports"
  }
}

resource "aws_instance" "terraform-test-2" {
	ami = "ami-0dc2d3e4c0f9ebd18"
	instance_type = "t2.micro"
	user_data = file("./modules/monitoring/user-data.sh")
  key_name = "monitoring-key"
  subnet_id = var.subnet_monitoring_instance
  vpc_security_group_ids = [var.vpc_security_group_monitoring]
  tags = {
		Name = "Terraform"
	}
}

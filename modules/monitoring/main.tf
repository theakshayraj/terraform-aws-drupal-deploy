resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_s3_bucket" "grafana-files-sg" {
  bucket = "grafana-files-sg"
  acl    = "private"

  tags = {
    Name        = "Grafana-resources"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "objects" {
  for_each = fileset("./modules/monitoring/data/grafana-files", "*")
  bucket = aws_s3_bucket.grafana-files-sg.id
  key = each.value
  source = "./modules/monitoring/data/grafana-files/${each.value}"
  etag = md5("./modules/monitoring/data/grafana-files/${each.value}")
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

resource "aws_iam_role" "ec2_cw_access_role" {
  name               = "ec2_cw_access_role"
  assume_role_policy = file("./modules/monitoring/data/assume_role_policy.json")
}

resource "aws_iam_instance_profile" "cw-grp_profile" {
  name = "cw-grp_profile"
  role = aws_iam_role.ec2_cw_access_role.name
}


resource "aws_iam_policy" "cw-metric-policy" {
  name        = "cw-metric-policy"
  description = "A policy for cloudwatch metrics"
  policy      = file("./modules/monitoring/data/cw-policy.json")
}

resource "aws_iam_policy" "s3-policy" {
  name        = "s3-policy"
  description = "A policy for s3 object download"
  policy      = file("./modules/monitoring/data/s3-policy.json")
}

resource "aws_iam_policy_attachment" "cw-attach" {
  name       = "cw-attachment"
  roles      = [aws_iam_role.ec2_cw_access_role.name]
  policy_arn = aws_iam_policy.cw-metric-policy.arn
}


resource "aws_iam_policy_attachment" "s3-attach" {
  name       = "s3-attachment"
  roles      = [aws_iam_role.ec2_cw_access_role.name]
  policy_arn = aws_iam_policy.s3-policy.arn
}

resource "aws_instance" "terraform-test-2" {
	ami = "ami-0dc2d3e4c0f9ebd18"
	instance_type = "t2.micro"
	user_data = file("./modules/monitoring/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.cw-grp_profile.name
  key_name = "monitoring-key"
  subnet_id = var.subnet_monitoring_instance
  vpc_security_group_ids = [var.vpc_security_group_monitoring]
  tags = {
		Name = "Terraform"
	}
}

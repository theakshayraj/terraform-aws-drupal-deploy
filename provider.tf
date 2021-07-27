
terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
  profile = "ttn"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Not required: currently used in conjunction with using
# icanhazip.com to determine local workstation external IP
# to open EC2 Security Group access to the Kubernetes cluster.
# See workstation-external-ip.tf for additional information.
provider "http" {}

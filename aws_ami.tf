# data "aws_ami" "packer_ami" {
#   most_recent = true
#   filter {
#     name   = "packer*"
#     values = ["available"]
#   }
# }


# # In resource block:
# resource "aws_instance" "web" {
#   ami           = data.aws_ami.packer_ami.id
#   instance_type = "t2.micro"
# }

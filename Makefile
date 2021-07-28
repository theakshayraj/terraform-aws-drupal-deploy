.PHONY: all fix validate build ami
 fix: 
	 packer fix packer.json

 validate:
	 packer validate packer.json

 build:
	 packer build -debug packer.json

 init:
	 terraform init

 plan:
	 terraform plan

 apply:
	 terraform apply

 destroy:
	 terraform destroy
	


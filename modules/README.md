# Terraform Modules

> A curated help menu of terraform modules used in the project.

[<img src="https://www.terraform.io/assets/images/logo-hashicorp-3f10732f.svg" align="right" width="600">](https://terraform.io)

[**Module 1**](#mod1): Autoscaling

[**Module 2**](#mod2): Application Load Balancer

[**Module 3**](#mod3): Database

[**Module 4**](#mod4): Network Configurations

<a id='mod1'></a>
## Module 1: Autoscaling

<a href="https://img.shields.io/badge/autoscaling-v4.1.0-%23c7c91c">
<img src="https://img.shields.io/badge/autoscaling-v4.1.0-%23c7c91c" /></a>

### Terraform module which creates autoscaling resources on AWS with launch template

<details>
  <summary><b>Variables</b></summary>
  
```
1. vpc_zone_identifier : Inputs a list of availability zones from network's 'security_group_asg' module
2. security_groups     : Inputs a list of security group ID's from network's 'security_group_id_asg' module
3. rds_endpt           : Inputs a string of RDS endpoint from db's 'rds_endpoint' output and passes it to userdata script   
4. target_group_arns   : Inputs a set of 'aws_alb_target_group' ARNs from alb's tg output
```
</details>

<details>
  <summary><b>Constants</b></summary>
  
```
1. min_size = 1                  #Minimun size of autoscaling group
2. max_size = 5                  #Maximum size of autoscaling group
3. desired_capacity = 2          #Number of concurrently running EC2 instances   
4. instance_type = "t2.micro"    #The type of the instance to launch
```
</details>

<a id='mod2'></a>
## Module 2: Application Load Balancer

<a href="https://img.shields.io/badge/alb-v6.0.0-%238c66d9">
<img src="https://img.shields.io/badge/alb-v6.0.0-%238c66d9" /></a>

### Terraform module which creates Application load balancer on AWS

<details>
  <summary><b>Variables</b></summary>
  
```
1. vpc_id           : Inputs the VPC id where all resources will be deployed from networks's 'vpc_id_all' module
2. subnets          : Inputs a list of subnets to associate with the load balancer from network's 'public_sn_asg' module
3. security_groups  : Inputs a list of security group ID's from network's 'security_group_id_asg' module   
```
</details>

<details>
  <summary><b>Constants</b></summary>
  
```
1. load_balancer_type = "application"         #Type of load balancer to create (application/network)
2. target_groups.backend_protocol = "HTTP"    #Protocol to be used by target groups
3. target_groups.backend_port = 80            #Port to be used by the target groups   
4. target_groups.target_type = "instance"     #Type of target group
```
</details>

<details>
  <summary><b>Outputs</b></summary>
  
```
1. tg : module.alb.target_group_arns    #ARNs of the target groups passed onto scaling group
```
</details>

<a id='mod3'></a>
## Module 3: Database

<a href="https://img.shields.io/badge/terraform--aws--rds--source-v3.0.0-ff69b4">
<img src="https://img.shields.io/badge/terraform--aws--rds--source-v3.0.0-ff69b4" /></a>
<a href="https://img.shields.io/badge/terraform--aws--rds--read-v3.0.0-ad7521">
<img src="https://img.shields.io/badge/terraform--aws--rds--read-v3.0.0-ad7521" /></a>

### Terraform module which creates RDS resources on AWS and reads from it

<details>
  <summary><b>Variables</b></summary>
  
```
  
```
</details>

<details>
  <summary><b>Constants</b></summary>
  
```

```
</details>

<details>
  <summary><b>Outputs</b></summary>
  
```

```
</details>


<a id='mod4'></a>
## Module 4: Network Configurations

<a href="https://img.shields.io/badge/vpc-v3.2.0-red">
<img src="https://img.shields.io/badge/vpc-v3.2.0-red" /></a>
<a href="https://img.shields.io/badge/security__group__asg-v4.0.0-brightgreen">
<img src="https://img.shields.io/badge/security__group__asg-v4.0.0-brightgreen" /></a>
<a href="https://img.shields.io/badge/security__group__rds-v4.0.0-important">
<img src="https://img.shields.io/badge/security__group__rds-v4.0.0-important" /></a>

### Terraform module which create VPC, security groups for auto scaling groups and RDS on AWS

<details>
  <summary><b>Variables</b></summary>
 
  ```
1.vpc_name             : Inputs the vpc name.
2. security_groups     : Inputs a list of security group ID's from network's 'security_group_id_asg' module  
 ```
</details>

<details>
  <summary><b>Constants</b></summary>
  
  ```
  1. cidr  : #cidr address
  2. egress port : #0-65535 open internet
  3. ingress port : #80 , 8080 , 2049 etc.
  ```

</details>

<details>
  <summary><b>Outputs</b></summary>
  
```
  1.vpc_id_all : #name of all vpc_id
  2.public_sn_asg : #all public subnets
  3.private_sn_asg :#all private subnets
  4.security_group_id_asg :#all security group id 
  5.security_group_id_rds :#all security group for rds

```
</details>


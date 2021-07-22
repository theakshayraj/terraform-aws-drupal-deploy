# Drupal Deployment on AWS using Terraform 

“Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently."
The goal of this project is to host Drupal site on AWS via Terraform  it's a cross-platform, extensible tool that codifies APIs into declarative configuration 
files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

#### The different areas taken into account involves:
- 1. Application Load Balancer with Autoscaling 
- 2. MySql Database
- 3. Monitoring using Prometheus and Grafana

Also, a dedicated module named Network aims to provide desired information to implement all combinations of arguments supported by AWS and latest stable version of Terraform

## Requirements

- 1. Install Terraform
- 2. Sign up for AWS 
- 3. A valid AMI, followed by next section

## AMI
If you run AWS EC2 instances in AWS, then you are probably familiar with the concept of pre-baking Amazon Machine Images (AMIs). 
That is, preloading all needed software and configuration on an EC2 instance, then creating an image of that. The resulting image
can then be used to launch new instances with all software and configuration pre-loaded. This process allows the EC2 instance to come 
online and be available quickly. It not only simplifies deployment of new instances but is especially useful when an instance is part of 
an Auto Scaling group and is responding to a spike in load. If the instance takes too long to be ready, it defeats the purpose of dynamic scaling.

## Summary of Resources
-  3 Security Groups
-  2 Running Instance in ASG
-  2 RDS(Primary & Replica) 


  

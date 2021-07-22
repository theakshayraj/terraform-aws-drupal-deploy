# Network Module
This module aims to implement ALL combinations of arguments supported by AWS and latest stable version of Terraform:

- 1.IPv4/IPv6 CIDR blocks
- 2.VPC endpoint prefix lists (use data source aws_prefix_list)
- 3.Access from source security groups
- 4.Named rules (see the rules here)
- 5.Named groups of rules with ingress (inbound) and egress (outbound) ports open for common scenarios (eg, ssh, http-80 see the whole list here)

Conditionally create security group and/or all required security group rules.
Ingress and egress rules can be configured in a variety of ways. See inputs section for all supported arguments and complete example for the complete use-case.


#### Here we are using three modules.
- 1.vpc module
   name = local.name
   Here name is a variable.
- 2.security module
- 3.security rds module

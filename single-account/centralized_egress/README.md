<!-- BEGIN_TF_DOCS -->
# AWS Hub and Spoke Architecture with an Inspection VPC - Single AWS Account (Centralized Egress)

## Prerequisites
* An AWS account with an IAM user with the appropriate permissions
* Terraform installed

## Code Principles:
* Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage
* Clone the repository
* Edit the variables.tf file in the project root directory. This file contains the information used to configure the Terraform code.

**Note** EC2 instances, and AWS Network Firewall endpoints will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Target Architecture

![Architecture diagram](../../images/single\_account\_centralizedegress.png)

## Deployment

* `terraform init` to initialize the environment.
* `terraform plan` to check the resources to create
* `terraform apply` to build the architecture.

## Clean-up

* `terraform destroy` will clean-up the resources created.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | > 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | > 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../modules/compute | n/a |
| <a name="module_iam_kms"></a> [iam\_kms](#module\_iam\_kms) | ../modules/iam_kms | n/a |
| <a name="module_inspection_vpc"></a> [inspection\_vpc](#module\_inspection\_vpc) | aws-ia/vpc/aws | 4.5.0 |
| <a name="module_network_firewall"></a> [network\_firewall](#module\_network\_firewall) | aws-ia/networkfirewall/aws | 1.0.2 |
| <a name="module_spoke_vpcs"></a> [spoke\_vpcs](#module\_spoke\_vpcs) | aws-ia/vpc/aws | = 4.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.tgw_route_default_to_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.tgw_route_table_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.tgw_route_table_spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.tgw_inspection_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.tgw_spoke_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.tgw_spoke_propagation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.tgw_spoke_propagation_inspection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Name of the project. | `string` | `"singleaccount-centralizedegress"` | no |
| <a name="input_inspection_vpc"></a> [inspection\_vpc](#input\_inspection\_vpc) | Inspection VPC definition. | `any` | <pre>{<br/>  "cidr_block": "10.129.0.0/24",<br/>  "number_azs": 2,<br/>  "private_subnet_netmask": 28,<br/>  "public_subnet_netmask": 28,<br/>  "tgw_subnet_netmask": 28<br/>}</pre> | no |
| <a name="input_spoke_vpcs"></a> [spoke\_vpcs](#input\_spoke\_vpcs) | Spoke VPCs definition. | `any` | <pre>{<br/>  "spoke-vpc-1": {<br/>    "cidr_block": "10.0.0.0/24",<br/>    "endpoint_subnet_netmask": 28,<br/>    "flow_log_config": {<br/>      "log_destination_type": "cloud-watch-logs",<br/>      "retention_in_days": 7<br/>    },<br/>    "instance_type": "t2.micro",<br/>    "number_azs": 2,<br/>    "tgw_subnet_netmask": 28,<br/>    "workload_subnet_netmask": 28<br/>  },<br/>  "spoke-vpc-2": {<br/>    "cidr_block": "10.0.1.0/24",<br/>    "endpoint_subnet_netmask": 28,<br/>    "flow_log_config": {<br/>      "log_destination_type": "cloud-watch-logs",<br/>      "retention_in_days": 7<br/>    },<br/>    "instance_type": "t2.micro",<br/>    "number_azs": 2,<br/>    "tgw_subnet_netmask": 28,<br/>    "workload_subnet_netmask": 28<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances"></a> [instances](#output\_instances) | EC2 instances created. |
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | AWS Transit Gateway ID. |
| <a name="output_transit_gateway_route_tables"></a> [transit\_gateway\_route\_tables](#output\_transit\_gateway\_route\_tables) | Transit Gateway Route Table. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPCs created. |
<!-- END_TF_DOCS -->
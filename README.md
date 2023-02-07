<!-- BEGIN_TF_DOCS -->
# AWS Hub and Spoke Architecture with an Inspection VPC - Terraform Sample

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with an Inspection VPC using AWS Network Firewall. The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes.

## Prerequisites
- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:
- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage
- Clone the repository
- Edit the variables.tf file in the project root directory

The variables.tf file contains the variables that are used to configure the Terraform code.

**Note** EC2 instances, VPC endpoints, and AWS Network Firewall endpoints will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Deployment

### AWS Network Firewall Policy

The AWS Network Firewall Policy is defined in the *policy.tf* file in the network\_firewall module directory. By default:

- All the SSH and RDP traffic is blocked by the Stateless engine.
- The Stateful engine follows Strict Rule Ordering, blocking all the traffic by default. Two rule groups allow ICMP traffic (between East/West traffic only), and HTTPS traffic to any **.amazon.com* domain.

#### Logging Configuration

This project configures both the alert and flow logs to respective AWS Cloudwatch Log Groups (both for the VPC Flow logs and AWS Network Firewall logs). In VPC Flow logs, you can also use Amazon S3. In Network Firewall, you can also use Amazon S3, or Amazon Kinesis Firehose.

To follow best practices, all the logs are encrypted at rest using AWS KMS. The KMS key (alongside the IAM roles needed) is created using the *iam\_kms* module.

## Target Architecture

![Architecture diagram](./images/architecture\_diagram.png)

### Cleanup

Remember to clean up after your work is complete. You can do that by doing `terraform destroy`.

Note that this command will delete all the resources previously created by Terraform.

------

## Security

See [CONTRIBUTING](https://github.com/aws-samples/aws-network-firewall-terraform/blob/main/CONTRIBUTING.md#security-issue-notifications) for more information.

------

## License

This library is licensed under the MIT-0 License. See the [LICENSE](https://github.com/aws-samples/aws-network-firewall-terraform/blob/main/LICENSE) file.

------

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.73.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_hubspoke"></a> [hubspoke](#module\_hubspoke) | aws-ia/network-hubandspoke/aws | 2.0.0 |
| <a name="module_spoke_vpcs"></a> [spoke\_vpcs](#module\_spoke\_vpcs) | aws-ia/vpc/aws | = 3.2.1 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.ssm_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flowlogs_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flowlogs_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.log_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_networkfirewall_firewall_policy.anfw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_icmp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_security_group.endpoints_vpc_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.spoke_vpc_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_kms_logs_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_role_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_rolepolicy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_inspection_vpc"></a> [inspection\_vpc](#input\_inspection\_vpc) | Inspection VPC definition. | `any` | <pre>{<br>  "cidr_block": "10.129.0.0/24",<br>  "number_azs": 2,<br>  "private_subnet_netmask": 28,<br>  "public_subnet_netmask": 28,<br>  "tgw_subnet_netmask": 28<br>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project. | `string` | `"hubspoke-inspection"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_spoke_vpcs"></a> [spoke\_vpcs](#input\_spoke\_vpcs) | Spoke VPCs definition. | `any` | <pre>{<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.0.0.0/24",<br>    "endpoint_subnet_netmask": 28,<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "tgw_subnet_netmask": 28,<br>    "workload_subnet_netmask": 28<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.0.1.0/24",<br>    "endpoint_subnet_netmask": 28,<br>    "flow_log_config": {<br>      "log_destination_type": "cloud-watch-logs",<br>      "retention_in_days": 7<br>    },<br>    "instance_type": "t2.micro",<br>    "number_azs": 2,<br>    "tgw_subnet_netmask": 28,<br>    "workload_subnet_netmask": 28<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances"></a> [instances](#output\_instances) | EC2 instances created. |
| <a name="output_network_firewall"></a> [network\_firewall](#output\_network\_firewall) | AWS Network Firewall ID. |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | AWS Transit Gateway ID. |
| <a name="output_transit_gateway_route_tables"></a> [transit\_gateway\_route\_tables](#output\_transit\_gateway\_route\_tables) | Transit Gateway Route Table. |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | SSM VPC endpoints created. |
| <a name="output_vpcs"></a> [vpcs](#output\_vpcs) | VPCs created. |
<!-- END_TF_DOCS -->
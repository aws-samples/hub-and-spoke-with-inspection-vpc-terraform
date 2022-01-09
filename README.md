---

---

# AWS Hub and Spoke Architecture with an Inspection VPC - Terraform Sample

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with an inspection VPC using AWS Network Firewall. The resources deployed and the architectural pattern they follow is purely for demonstration/testing  purposes.


## Prerequisites
- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:

- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage
- Clone the repository
- Edit the variables.tf file in the project root directory

The variables.tf file contains the variables that are used to configure the Terraform code.

**** Note **** If the ec2_multi_subnet variable is set to true, an EC2 compute instance will be deployed into every Spoke Private subnet, with 2 x Spokes and 3 x Availablity Zones this means 6 EC2 instances. **Please** leave as false to avoid costs unless you are happy to deploy more instances and accept additional costs.

## Deplpoyment

## Input Variables

### Project variables

These variables are defined in a variable block:

```
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Terraform_Project"
}
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}
```



| Name         | Description             | Type   | Default           | Required |
| ------------ | ----------------------- | ------ | ----------------- | -------- |
| project_name | The name of the project | string | Terraform_Project | Yes      |
| region       | AWS region to deploy in | string | eu-west-2         | Yes      |



### Infrastructure Spoke Variables

These variables are defined in a variable block:

```
variable "spoke" {
  description = "VPC Spokes"
  type        = map(any)
  default = {
    "spoke-vpc-1" = {
      cidr_block           = "10.11.0.0/16",
      instances_per_subnet = 1,
      instance_type        = "t2.micro",
      spoke                = true
      nat_gw               = false
    }
}
```

| Name                 | Description                                                  | Type    | Default      | Required |
| -------------------- | ------------------------------------------------------------ | ------- | ------------ | -------- |
| Map Key              | Name of the spoke                                            | string  | spoke-vpc-1  | Yes      |
| cidr_block           | The CIDR block to assing to the spoke                        | string  | 10.11.0.0/16 | Yes      |
| instances_per_subnet | Number of EC2 compute instances to deploy                    | integer | 1            | Yes      |
| instance_type        | Type of EC2 compute instance to deploy                       | string  | t2.micro     | Yes      |
| spoke                | Define if the resource is a spoke (false = Inspection VPC)   | bool    | true         | Yes      |
| nat_gw               | Deploy a NAT Gataway in the VPC                              | bool    | false        | Yes      |
| ec2_multi_subnet     | Deploy EC2 Instances into a single (first) subnet or all subnets | bool    | false        | Yes      |

------

### AWS Network Firewall

#### Policy

The AWS Network Firewall Policy is defined in the policy.tf file in the network_firewall directory. 

#### Logging Configuration

This project configures both the alert and flow logs to respective AWS Cloudwatch Log Groups. Amazon S3 can also be used as a logging destination.

## Target Architecture

![Architecture diagram](./images/architecture_diagram.png)

### Cleanup

Remember to clean up after your work is complete. You can do that by doing `terraform destroy`.

Note that this command will delete all the resources previously created by Terraform.

------

## Security

See [CONTRIBUTING](https://github.com/aws-samples/aws-network-firewall-terraform/blob/main/CONTRIBUTING.md#security-issue-notifications) for more information.

------

## License

This library is licensed under the MIT-0 License. See the [LICENSE](https://github.com/aws-samples/aws-network-firewall-terraform/blob/main/LICENSE) file.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.71.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.2.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.1.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_external"></a> [external](#provider\_external) | 2.2.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_network_firewall"></a> [aws\_network\_firewall](#module\_aws\_network\_firewall) | ./modules/network_firewall | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ./modules/iam_roles | n/a |
| <a name="module_inspection_vpc"></a> [inspection\_vpc](#module\_inspection\_vpc) | ./modules/inspection_vpc | n/a |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | n/a |
| <a name="module_spoke_vpc"></a> [spoke\_vpc](#module\_spoke\_vpc) | ./modules/spoke_vpc | n/a |
| <a name="module_tgw"></a> [tgw](#module\_tgw) | ./modules/tgw | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ./modules/endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/2.1.0/docs/resources/file) | resource |
| [random_pet.key_name](https://registry.terraform.io/providers/hashicorp/random/3.1.0/docs/resources/pet) | resource |
| [tls_private_key.private_key](https://registry.terraform.io/providers/hashicorp/tls/3.1.0/docs/resources/private_key) | resource |
| [external_external.curlip](https://registry.terraform.io/providers/hashicorp/external/2.2.0/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_multi_subnet"></a> [ec2\_multi\_subnet](#input\_ec2\_multi\_subnet) | Multi subnet Instance Deployment | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"aws-hub-and-spoke-demo"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | `"eu-west-2"` | no |
| <a name="input_spoke"></a> [spoke](#input\_spoke) | VPC Spokes | `map(any)` | <pre>{<br>  "inspection-vpc": {<br>    "cidr_block": "10.129.0.0/16",<br>    "instance_type": "t2.micro",<br>    "instances_per_subnet": 1,<br>    "nat_gw": true,<br>    "spoke": false<br>  },<br>  "spoke-vpc-1": {<br>    "cidr_block": "10.11.0.0/16",<br>    "instance_type": "t2.micro",<br>    "instances_per_subnet": 1,<br>    "nat_gw": false,<br>    "spoke": true<br>  },<br>  "spoke-vpc-2": {<br>    "cidr_block": "10.12.0.0/16",<br>    "instance_type": "t2.micro",<br>    "instances_per_subnet": 1,<br>    "nat_gw": false,<br>    "spoke": true<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anfw_output"></a> [anfw\_output](#output\_anfw\_output) | Firewall module outputs |
| <a name="output_compute"></a> [compute](#output\_compute) | Compute Module Output |
| <a name="output_firewall"></a> [firewall](#output\_firewall) | Inspection Module VPCs |
| <a name="output_inspection_routes"></a> [inspection\_routes](#output\_inspection\_routes) | Inspection Route Module Output |
| <a name="output_spoke_routes"></a> [spoke\_routes](#output\_spoke\_routes) | Spoke Route Module Output |
| <a name="output_terraform_iam_role"></a> [terraform\_iam\_role](#output\_terraform\_iam\_role) | IAM Role |
| <a name="output_tgw"></a> [tgw](#output\_tgw) | TGW ID |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | The ID of the VPC |
<!-- END_TF_DOCS -->
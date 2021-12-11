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

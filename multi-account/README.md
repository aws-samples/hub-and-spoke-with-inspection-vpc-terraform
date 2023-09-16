# AWS Hub and Spoke Architecture with an Inspection VPC - Multi-AWS Accounts

This repository contains terraform code to deploy a sample AWS Hub and Spoke architecture with an Inspection VPC using AWS Network Firewall - in a multi-Account environment. The resources deployed and the architectural pattern they follow is purely for demonstration/testing purposes.

## Prerequisites
* Three AWS Accounts with an IAM user with the appropriate permissions
* The AWS Accounts should be part of the same AWS Organizations
* Amazon VPC IPAM should be enabled in the AWS Organization
    * The *Networking Account* should be configured as the delegated Account to manage VPC IPAM.
    * Check the [VPC IPAM documentation](https://docs.aws.amazon.com/vpc/latest/ipam/enable-integ-ipam.html) for more information about the required configuration.
* Terraform installed

## Code Principles:
* Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage
* Clone the repository
* Edit the variables.tf file in each of the directories (*security-account*, *networking-account*, *spoke-account*). Each file contains the information used to configure the Terraform code in each AWS Account.

**Note** EC2 instances, VPC endpoints, and AWS Network Firewall endpoints will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Target Architecture

![Architecture diagram](../images/multi_account.png)

## Deployment

* `terraform init` in each folder to download Terraform provider and modules.
* Step 1: Deploy the resources of the *Security Account*
    * Move to the specific folder - `cd security-account`
    * Deploy the resources using `terraform apply`
* Step 2: Deploy the resources of the *Networking Account*
    * Move to the specific folder - `cd networking-account`
    * This folder needs the Account ID of the *Security Account* (var.security_account) to obtain the Secrets Manager secret containing the Network Firewall Policy ID. We recommend the use of a [.tfvars file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files:~:text=several%20different%20variables.-,Variable%20Definitions%20(.tfvars)%20Files,-To%20set%20lots) to pass this value.
    * Deploy the resources using `terraform apply`
    * The Transit Gateway routing (Spoke VPCs) will be deployed after we deploy the resources from the *Spoke Account*
* Step 3: Deploy the resources of the *Spoke Account*
    * Move to the specific folder - `cd spoke-account`
    * This folder needs the Account ID of the *Networking Account* (var.networking_account) to obtain the Secrets Manager secrets containing the Transit Gateway ID and VPC IPAM pool ID. We recommend the use of a [.tfvars file](https://developer.hashicorp.com/terraform/language/values/variables#variable-definitions-tfvars-files:~:text=several%20different%20variables.-,Variable%20Definitions%20(.tfvars)%20Files,-To%20set%20lots) to pass this value.
    * Deploy the resources using `terraform apply`
* Step 4: Creating the Spoke VPC attachments routing in the *Networking Account*
    * Move to the specific folder - `cd networking-account`
    * Uncomment lines 48 - 54 & 95 - 99 in **main.tf** file. 
        * These lines will get the information of the Spoke VPC attachments - shared via Secrets Manager by the *Spoke Account* - and create the corresponding Transit Gateway resources (route tables, associations, propagations, static routes)
    * `terraform apply` will create the resources.

## Clean-up

* Step 1: Remove the Transit Gateway routing configuration
    * Move to the specific folder - `cd networking-account`
    * Comment lines 48 - 54 & 95 - 99 in **main.tf** file.
        * Removing these resources (and data sources) will remove the Transit Gateway routing, allowing later to destroy the VPC attachments in the *Spoke Account*
    * `terraform apply` will destroy the resources
* Step 2: Clean-up *Spoke Account*.
    * Move to the specific folder - `cd spoke-account`
    * `terraform destroy` will clean-up all the resources in the Account.
* Step 3: Clean-up *Networking Account*
    * Move to the specific folder - `cd networking-account`
    * `terraform destroy` will clean-up all the resources in the Account. 
* Step 4: Clean-up *Security Account*
    * Move to the specific folder - `cd security-account`
    * `terraform destroy` will clean-up all the resources in the Account. 

## AWS Network Firewall Policy

The AWS Network Firewall Policy is defined in the *policy.tf* file in the network_firewall module directory. By default:

* All the SSH and RDP traffic is blocked by the Stateless engine.
* The Stateful engine follows Strict Rule Ordering, blocking all the traffic by default. The only rule group allow HTTPS traffic to any **.amazon.com* domain.

## Security

See [CONTRIBUTING](../CONTRIBUTING.md) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](../LICENSE) file.
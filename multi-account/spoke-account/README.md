<!-- BEGIN_TF_DOCS -->
# Spoke AWS Account

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 5.16.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 5.16.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ../modules/compute | n/a |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | aws-ia/vpc/aws | 4.4.2 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret_version.vpc_information](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.aws_spoke_account](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/caller_identity) | data source |
| [aws_secretsmanager_secret.ipam_pool_id](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.tgw_id](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret.vpc_information](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.ipam_pool_id](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.tgw_id](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_networking_account"></a> [networking\_account](#input\_networking\_account) | Networking Account ID. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Account Identifier. | `string` | `"spoke-account"` | no |
| <a name="input_secrets_names"></a> [secrets\_names](#input\_secrets\_names) | AWS Secrets Manager secrets name. | `map(string)` | <pre>{<br>  "networking_account_attachments": "network-account-vpc-attachments",<br>  "networking_account_ipam": "networking-account-ipam-pool-id",<br>  "networking_account_tgw": "networking-account-transit-gateway-id"<br>}</pre> | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | VPC information. | `any` | <pre>{<br>  "vpc1": {<br>    "instance_type": "t3.micro",<br>    "number_azs": 2,<br>    "routing_domain": "prod"<br>  },<br>  "vpc2": {<br>    "instance_type": "t3.micro",<br>    "number_azs": 2,<br>    "routing_domain": "nonprod"<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
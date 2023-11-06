<!-- BEGIN_TF_DOCS -->
# Networking AWS Account

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
| <a name="module_hubspoke"></a> [hubspoke](#module\_hubspoke) | aws-ia/network-hubandspoke/aws | 3.2.0 |
| <a name="module_ipam"></a> [ipam](#module\_ipam) | aws-ia/ipam/aws | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.secrets_key](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/kms_key) | resource |
| [aws_ram_principal_association.principal_association](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.transit_gateway_share](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.resource_share](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_resource_share) | resource |
| [aws_secretsmanager_secret.ipam_pool](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.spoke_attachments](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.ipam_pool](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.aws_networking_account](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_kms_document](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_resource_policy_read](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_resource_policy_write](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/organizations_organization) | data source |
| [aws_secretsmanager_secret.firewall_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.firewall_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_account"></a> [security\_account](#input\_security\_account) | Security Account ID. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Account Identifier. | `string` | `"networking-account"` | no |
| <a name="input_secrets_names"></a> [secrets\_names](#input\_secrets\_names) | AWS Secrets Manager secrets name. | `map(string)` | <pre>{<br>  "networking_account_attachments": "network-account-vpc-attachments",<br>  "networking_account_ipam": "networking-account-ipam-pool-id",<br>  "networking_account_tgw": "networking-account-transit-gateway-id",<br>  "security_account": "security-account-firewall-policy-arn"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
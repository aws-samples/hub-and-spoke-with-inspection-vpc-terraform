<!-- BEGIN_TF_DOCS -->
# Security AWS Account

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.secrets_key](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/kms_key) | resource |
| [aws_networkfirewall_firewall_policy.central_inspection_policy](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_domains](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_tcp](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.drop_remote](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/networkfirewall_rule_group) | resource |
| [aws_ram_principal_association.principal_association](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.firewall_policy_share](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.resource_share](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/ram_resource_share) | resource |
| [aws_secretsmanager_secret.firewall_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.firewall_policy_arn](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.aws_security_account](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_kms_document](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/5.16.2/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Account Identifier. | `string` | `"security-account"` | no |
| <a name="input_network_supernet"></a> [network\_supernet](#input\_network\_supernet) | Network supernet. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | AWS Secrets Manager secret name. | `string` | `"security-account-firewall-policy-arn"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
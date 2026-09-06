# Bootstrap runs locally with an authorized account administrator, not inside
# the application workspace. Do not upload this state or credentials to CI.
terraform {
  required_version = ">= 1.15.1, < 2.0.0"
  required_providers { aws = { source = "hashicorp/aws", version = "= 6.45.0" } }
}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["180840262641"]
}
variable "tfc_organization" { type = string }
variable "tfc_project" { type = string }
variable "existing_oidc_provider_arn" {
  type        = string
  default     = null
  description = "Use the account's existing app.terraform.io OIDC provider when present."
}
data "aws_kms_alias" "ebs" { name = "alias/aws/ebs" }
resource "aws_iam_openid_connect_provider" "tfc" {
  count          = var.existing_oidc_provider_arn == null ? 1 : 0
  url            = "https://app.terraform.io"
  client_id_list = ["aws.workload.identity"]
}
locals {
  oidc_arn = var.existing_oidc_provider_arn != null ? var.existing_oidc_provider_arn : aws_iam_openid_connect_provider.tfc[0].arn
}
resource "aws_iam_role" "tfc" {
  name = "flask-lab-tfc-execution"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{
    Effect    = "Allow"
    Principal = { Federated = local.oidc_arn }
    Action    = "sts:AssumeRoleWithWebIdentity"
    Condition = {
      StringEquals = { "app.terraform.io:aud" = "aws.workload.identity" }
      StringLike   = { "app.terraform.io:sub" = [for env in ["dev", "stage", "prod"] : "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:flask-lab-${env}:run_phase:*"] }
    }
  }] })
}
resource "aws_iam_role_policy" "tfc" {
  name = "flask-lab-provisioning"
  role = aws_iam_role.tfc.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["ec2:Describe*"], Resource = "*", Condition = { StringEquals = { "aws:RequestedRegion" = "us-east-1" } } },
    # EC2 create/read dependency permissions require wildcard resources here.
    # This role is region-scoped, but NOT a complete resource-isolation boundary;
    # review its policy before use in an account with non-lab workloads.
    { Effect = "Allow", Action = ["ec2:RunInstances", "ec2:TerminateInstances", "ec2:StartInstances", "ec2:StopInstances", "ec2:ModifyInstanceAttribute", "ec2:ModifyInstanceCreditSpecification", "ec2:CreateTags", "ec2:DeleteTags", "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:ModifyVpcAttribute", "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:ModifySubnetAttribute", "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:CreateRoute", "ec2:DeleteRoute", "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable", "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupIngress", "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupIngress", "ec2:RevokeSecurityGroupEgress", "ec2:ModifySecurityGroupRules"], Resource = "*", Condition = { StringEquals = { "aws:RequestedRegion" = "us-east-1" } } },
    { Effect = "Allow", Action = ["iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:TagRole", "iam:UntagRole", "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile", "iam:TagInstanceProfile", "iam:UntagInstanceProfile", "iam:ListInstanceProfilesForRole"], Resource = ["arn:aws:iam::180840262641:role/flask-lab-*-instance", "arn:aws:iam::180840262641:instance-profile/flask-lab-*-instance"] },
    { Effect = "Allow", Action = ["iam:AttachRolePolicy", "iam:DetachRolePolicy"], Resource = "arn:aws:iam::180840262641:role/flask-lab-*-instance", Condition = { ArnEquals = { "iam:PolicyARN" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" } } },
    { Effect = "Allow", Action = ["iam:PassRole"], Resource = "arn:aws:iam::180840262641:role/flask-lab-*-instance", Condition = { StringEquals = { "iam:PassedToService" = "ec2.amazonaws.com" } } },
    { Effect = "Allow", Action = ["ssm:GetParameter"], Resource = "arn:aws:ssm:us-east-1::parameter/aws/service/ami-amazon-linux-latest/*" },
    { Effect = "Allow", Action = ["kms:ListAliases"], Resource = "*" },
    { Effect = "Allow", Action = ["kms:DescribeKey", "kms:Decrypt", "kms:GenerateDataKeyWithoutPlaintext", "kms:ReEncrypt*", "kms:CreateGrant"], Resource = data.aws_kms_alias.ebs.target_key_arn }
  ] })
}
output "execution_role_arn" { value = aws_iam_role.tfc.arn }

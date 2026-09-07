module "application" {
  source             = "../modules/flask-app"
  environment        = var.environment
  app_id             = var.app_id
  app_version        = var.app_version
  ami_id             = data.aws_ssm_parameter.ami.value
  subnet_id          = aws_subnet.lab.id
  security_group_ids = [aws_security_group.app.id]
  instance_profile   = aws_iam_instance_profile.instance.name
  kms_alias_arn      = data.aws_kms_alias.ebs.arn
  servers            = var.servers
  depends_on         = [aws_route.internet, aws_route_table_association.lab, aws_iam_role_policy_attachment.ssm]
}

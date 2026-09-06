terraform {
  required_version = ">= 1.15.1, < 2.0.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "= 6.45.0" }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  default_tags { tags = { Project = "flask-learning-lab", Environment = var.environment, ManagedBy = "Terraform" } }
}

data "aws_availability_zones" "available" { state = "available" }
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
data "aws_kms_alias" "ebs" { name = "alias/aws/ebs" }

resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "flask-${var.environment}" }
}
resource "aws_subnet" "lab" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = data.aws_availability_zones.available.names[0]
}
resource "aws_internet_gateway" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route_table" "lab" { vpc_id = aws_vpc.lab.id }
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.lab.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab.id
}
resource "aws_route_table_association" "lab" {
  subnet_id      = aws_subnet.lab.id
  route_table_id = aws_route_table.lab.id
}
resource "aws_security_group" "app" {
  name_prefix = "flask-${var.environment}-"
  description = "Flask lab access from approved client CIDR"
  vpc_id      = aws_vpc.lab.id
}
resource "aws_vpc_security_group_ingress_rule" "app" {
  count             = var.client_cidr == null ? 0 : 1
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = var.client_cidr
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}
resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_iam_role" "instance" {
  name               = "flask-lab-${var.environment}-instance"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "instance" {
  name = "flask-lab-${var.environment}-instance"
  role = aws_iam_role.instance.name
}
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
output "instances" { value = module.application.instances }
output "urls" { value = { for name, server in module.application.instances : name => "http://${server.public_ip}:8080" } }


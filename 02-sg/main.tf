module "database_sg" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for DB MySQL instances"
  common_tags = var.comman_tags
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "db"
}
module "backend_sg" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for backend instances"
  common_tags = var.comman_tags
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "backend"
}
module "frontend_sg" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for frontend instances"
  common_tags = var.comman_tags
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "frontend"
}
module "bastion_sg" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for bastion instance"
  common_tags = var.comman_tags
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "bastion"
}
module "ansible_sg" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for ansible instance"
  common_tags = var.comman_tags
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  sg_name = "ansible"
}
#below are all ingress rules for the above security groups
# DB is allowing traffic from Backend
resource "aws_security_group_rule" "db_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  #source security group id is nothing but from where you are getting traffic
  #source_security_group_id = data.aws_ssm_parameter.backend_sg_id.value
  #without data source , y can get the sg id as below
  source_security_group_id = module.backend_sg.sg_id
  #security_group_id = data.aws_ssm_parameter.db_sg_id.value
  security_group_id = module.database_sg.sg_id
}
# DB is allowing traffic from Bastion
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  #source security group id is nothing but from where you are getting traffic
  #source_security_group_id = data.aws_ssm_parameter.backend_sg_id.value
  #without data source , y can get the sg id as below
  source_security_group_id = module.bastion_sg.sg_id
  #security_group_id = data.aws_ssm_parameter.db_sg_id.value
  security_group_id = module.database_sg.sg_id
}

# backend is allowing traffic from frontend
resource "aws_security_group_rule" "backend_frontend" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  #source_security_group_id = data.aws_ssm_parameter.frontend_sg_id.value
  source_security_group_id = module.frontend_sg.sg_id
  #security_group_id = data.aws_ssm_parameter.backend_sg_id.value
  security_group_id = module.backend_sg.sg_id
}
# backend is allowing traffic from bastion
resource "aws_security_group_rule" "backend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}
# backend is allowing traffic from ansible
resource "aws_security_group_rule" "backend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}


# frontend is allowing traffic from internet
resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #security_group_id = data.aws_ssm_parameter.frontend_sg_id.value
  security_group_id = module.frontend_sg.sg_id
}
# frontend is allowing traffic from bastion
resource "aws_security_group_rule" "frontend_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  #security_group_id = data.aws_ssm_parameter.frontend_sg_id.value
  security_group_id = module.frontend_sg.sg_id
}
# frontend is allowing traffic from ansible
resource "aws_security_group_rule" "frontend_ansible" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.ansible_sg.sg_id
  #security_group_id = data.aws_ssm_parameter.frontend_sg_id.value
  security_group_id = module.frontend_sg.sg_id
}
# bastion is allowing traffic from internet/public
resource "aws_security_group_rule" "bastion_ingress_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}
# ansible is allowing traffic from internet/public
resource "aws_security_group_rule" "ansible_ingress_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ansible_sg.sg_id
}
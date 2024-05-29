# creating backend server in private subnet using opensource module
module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-backend"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  subnet_id              = local.backend_subnet_id
  ami = data.aws_ami.ami_info.id

  tags = merge(
    var.comman_tags,
    {
        Name = "${var.project_name}-${var.environment}-backend"
    }
  )
}

# creating frontend server in public subnet using opensource module
module "frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-frontend"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  subnet_id              = local.frontend_subnet_id
  ami = data.aws_ami.ami_info.id

  tags = merge(
    var.comman_tags,
    {
        Name = "${var.project_name}-${var.environment}-frontend"
    }
  )
}
# creating ansible server in public subnet using opensource module
module "ansible" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-ansible"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.ansible_sg_id.value]
  subnet_id              = local.frontend_subnet_id
  ami = data.aws_ami.ami_info.id
  user_data = file("expense.sh")
  # ansible server will do the configuration only when backend and frontend servers are created
  depends_on = [ module.backend,module.frontend ]

  tags = merge(
    var.comman_tags,
    {
        Name = "${var.project_name}-${var.environment}-ansible"
    }
  )
}

# creating R53 records for backend and frontend servers using opensource module
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "backend" # backend.goadd.fun
      type    = "A"
      ttl     = 1
      records = [
        module.backend.private_ip
      ]
    },
    {
      name    = "frontend" # frontend.goadd.fun
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.private_ip
      ]
    },
    {
      name    = "" # goadd.fun
      type    = "A"
      ttl     = 1
      records = [
        module.frontend.public_ip
      ]
    }
  ]
}
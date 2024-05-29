locals {
  backend_subnet_id = element(split(",", data.aws_ssm_parameter.backend_subnet_ids.value), 0)
  frontend_subnet_id = element(split(",", data.aws_ssm_parameter.frontend_subnet_ids.value), 0)
  # convert StringList to list and get first element from subnet ids list
}
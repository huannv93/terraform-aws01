module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.12.0"
  
  name    = "${var.project}-vpc"
  cidr    = var.vpc_cidr
  azs     = data.aws_availability_zones.available.names

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true

...// tao Security Group cho VPC tao o tren 
Cho phép truy cập port 80 của ALB từ mọi nơi.
Cho phép truy cập port 80 của các EC2 từ ALB.
Cho phép truy cập port 5432 của RDS từ EC2.
...//

module "alb_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port        = 80
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "web_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port        = 80
      security_groups = [module.lb_sg.security_group.id]
    }
  ]
}

module "db_sg" {
  source = "terraform-in-action/sg/aws"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      port            = 5432
      security_groups = [module.web_sg.security_group.id]
    }
  ]
}

// output giatrri
//Để truy cập giá trị của một module, ta dùng systax sau module.<name>.<output_value>, ví dụ để truy cập giá trị lb_sg id của networking module.

output "vpc" {
  value = module.vpc
}

output "sg" {
  value = {
    lb = module.lb_sg.security_group.id
    web = module.web_sg.security_group.id
    db = module.db_sg.security_group.id
  }
}

}


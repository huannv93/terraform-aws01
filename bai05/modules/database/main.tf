resource "aws_db_subnet_group" "default" {
  name       = "main"
#  subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]
  subnet_ids = [var.database_subnets]

  tags = {
    Name = "My DB subnet group"
  }
}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_instance" "database" {
  allocated_storage      = 20
  engine                 = "postgresql"
  engine_version         = "12.7"
  instance_class         = "db.t2.micro"
  identifier             = "${var.project}-db-instance"
  db_name                = "series"
  username               = "series"
  password               = random_password.password.result
  db_subnet_group_name   = var.vpc.database_subnet_group
  vpc_security_group_ids = [var.sg.db]
  skip_final_snapshot    = true
}


#Ở trên AWS, khi ta tạo RDS, yêu cầu ta cần phải có một subnet groups trước, rồi RDS mới được deploy lên trên subnet group đó.
# RDS DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  db_name                 = "MyWebApiDB"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.web_sg.id]
  skip_final_snapshot     = true
  backup_retention_period = 0
  monitoring_interval     = 0
  publicly_accessible     = false
}
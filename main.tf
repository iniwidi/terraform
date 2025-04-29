provider "aws" {
  region = var.region
}

# S3 Bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "my-webapp-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# VPC dan Subnet default
data "aws_vpc" "default" {
  default = true
}

# Perubahan di sini - menggunakan aws_subnets sebagai ganti aws_subnet_ids
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, HTTPS, SSH, MySQL"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true  # Mengganti security_groups dengan self
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c1907b6d738188e5" # Ubuntu 22.04 LTS - ap-southeast-1
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]  # Perubahan di sini

  # Ganti ini:
  #security_groups = [aws_security_group.web_sg.name]

  # Menjadi ini:
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  key_name      = "wid" # ganti dengan nama key pair kamu

  tags = {
    Name = "WebAppInstance"
  }
}

# RDS Instance
resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  db_name              = "MyWebApiDB"  # Ganti 'name' dengan 'db_name' untuk MySQL
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  skip_final_snapshot  = true

  backup_retention_period = 0
  monitoring_interval     = 0
  publicly_accessible    = false  # Disarankan untuk keamanan
}

resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default.ids  # Perubahan di sini
}
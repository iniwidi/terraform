output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}
widianto@ID-LPT-073:~/terraform$ cat variables.tf
variable "region" {
  default = "ap-southeast-1"
}

variable "db_username" {
  default = "tempAdmin"
}

variable "db_password" {
  default = "tempAdmin954*"
}
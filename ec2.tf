# EC2 Instance
resource "aws_instance" "web" {
  ami                    = "ami-0c1907b6d738188e5" # Ubuntu 22.04 LTS - ap-southeast-1
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "wid" # Ganti dengan nama key pair kamu
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "WebAppInstance"
  }
}

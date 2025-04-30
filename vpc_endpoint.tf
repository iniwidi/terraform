# Ambil default route table
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
  default_for_az = true
}

# VPC Endpoint untuk S3 (Gateway Endpoint)
resource "aws_vpc_endpoint" "s3" {
  vpc_id             = data.aws_vpc.default.id
  service_name       = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = [data.aws_route_table.default.id]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}

# S3 Bucket Policy untuk membatasi akses hanya dari VPC Endpoint
resource "aws_s3_bucket_policy" "restrict_to_vpc_endpoint" {
  bucket = aws_s3_bucket.app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAccessFromVPCEOnly",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = [
          "${aws_s3_bucket.app_bucket.arn}",
          "${aws_s3_bucket.app_bucket.arn}/*"
        ],
        Condition = {
          StringNotEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      }
    ]
  })
}

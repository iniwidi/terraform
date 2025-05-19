resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "my-webapp-bucket-${random_id.bucket_id.hex}"
  force_destroy = true
}

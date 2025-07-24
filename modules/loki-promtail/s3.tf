 

resource "aws_s3_bucket" "loki_storage" {
  bucket = "${var.loki_storage_bucket}-${random_id.suffix.hex}" # Globally unique name
  region =  data.aws_region.current.id
  tags = {
    Name        = "Loki Storage"
    Environment = "Production"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

/*
# Enable versioning (recommended for Loki)
resource "aws_s3_bucket_versioning" "loki_versioning" {
  bucket = aws_s3_bucket.loki_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}
*/
# Block public access (security best practice)
resource "aws_s3_bucket_public_access_block" "loki_block_public" {
  bucket = aws_s3_bucket.loki_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
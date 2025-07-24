 

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



resource "null_resource" "s3_force_delete" {
  triggers = {
    bucket_name = aws_s3_bucket.loki_storage.name  # Trigger re-creation if bucket name changes
    region_name = data.aws_region.current.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      # Check if bucket exists first
      if aws s3 ls "s3://${self.triggers.bucket_name}" --no-sign-request --region ${self.triggers.region_name} 2>&1 | grep -q 'NoSuchBucket'; then
        echo "Bucket ${self.triggers.bucket_name} does not exist"
        exit 0
      fi

      # Empty and delete bucket
      aws s3 rm "s3://${self.triggers.bucket_name}" --recursive --region ${self.triggers.region_name} && \
      aws s3 rb "s3://${self.triggers.bucket_name}" --force --region ${self.triggers.region_name}
    EOT

  
  }
  depends_on = [ aws_s3_bucket.loki_storage ]
}
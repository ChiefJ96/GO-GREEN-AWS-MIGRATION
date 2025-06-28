// modules/s3/main.tf

resource "aws_s3_bucket" "documents" {
  bucket = "gogreen-documents"
  force_destroy = true

  tags = {
    Name        = "GoGreenDocuments"
    Environment = "Production"
  }
}

# Enable encryption with AWS KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enforce HTTPS-only access
resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.documents.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowSSLRequestsOnly",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "${aws_s3_bucket.documents.arn}/*",
          "${aws_s3_bucket.documents.arn}"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Lifecycle policy to move data to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.documents.id

  rule {
    id     = "archive-old-docs"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure AWS provider and creds
provider "aws" {
  #region                  = "us-east-1"
  #shared_config_files     = ["/home/ec2-user/.aws/config"]
  #shared_credentials_files = ["/home/ec2-user/.aws/credentials"]
  profile                 = "default"
}

# Creating bucket
resource "aws_s3_bucket" "website" {
  bucket = "terra-bucket-for-lab2dovbah"

  tags = {
    Name        = "Website"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  restrict_public_buckets = false
  ignore_public_acls      = true
}

data "aws_iam_policy_document" "website_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website_read.json
}

resource "aws_s3_object" "indexfile" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "./src/index.html"
  content_type = "text/html"
}

output "website_endpoint" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}

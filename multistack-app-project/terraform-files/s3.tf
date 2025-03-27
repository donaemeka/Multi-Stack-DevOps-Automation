# Remote State Configuration
resource "aws_s3_bucket" "state-s3-store"{
    bucket         = var.state-s3-store
   
  }

resource "aws_s3_bucket_versioning" "state-s3-store" {
  bucket = aws_s3_bucket.state-s3-store.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.terraform-state-lock
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}
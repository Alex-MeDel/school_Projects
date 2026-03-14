# ==========================================
# S3 BOOTSTRAP STORAGE
# Description: Provisions a temporary, randomized S3 bucket to store 
# configuration scripts, bypassing EC2 user_data size limits and 
# formatting constraints.
# ==========================================

resource "aws_s3_bucket" "bootstrap" { # bootstrap is the nickname I chose for the s3 bucket
  bucket        = "main-bootstrap-${random_id.bucket_suffix.hex}" # Must have random numbers to be unique
  force_destroy = true # important!, without this the terraform destroy would not be as effective and AWS will give out errors each deployment
  tags          = { Name = "main-bootstrap-scripts" } # this is for billing according to Claude AI
}

# Creates "randomness" for block above
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ------------------------------------------
# S3 OBJECT UPLOADS (Scripts & Configurations)
# ------------------------------------------
resource "aws_s3_object" "ubuntu_script" {
  bucket = aws_s3_bucket.bootstrap.id # Where to put file
  key    = "ubuntu_bootstrap.sh" # file name inside the s3 bucket
  source = "${path.module}/scripts/ubuntu_bootstrap.sh" # where is file in local computer
  etag   = filemd5("${path.module}/scripts/ubuntu_bootstrap.sh") # This was a Claude AI recommendation, it calculates math hash (MD5) of lcal file
  # if you open script and change a single line and save, the hash changes, and when terraform apply is ran, it comparates hashes, realizes changes and uploads new version
}

resource "aws_s3_object" "RHEL_script" {
  bucket = aws_s3_bucket.bootstrap.id # Where to put file
  key    = "RHEL_bootstrap.sh" # file name inside the s3 bucket
  source = "${path.module}/scripts/RHEL_bootstrap.sh" # where is file in local computer
  etag   = filemd5("${path.module}/scripts/RHEL_bootstrap.sh") # This was a Claude AI recommendation, it calculates math hash (MD5) of lcal file
  # if you open script and change a single line and save, the hash changes, and when terraform apply is ran, it comparates hashes, realizes changes and uploads new version
}

resource "aws_s3_object" "windows_script" {
  bucket = aws_s3_bucket.bootstrap.id
  key    = "windows_bootstrap.ps1"
  source = "${path.module}/scripts/windows_bootstrap.ps1"
  etag   = filemd5("${path.module}/scripts/windows_bootstrap.ps1")
}


provider "aws" {
  region = var.aws_region
}
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "my-terraform-state-lock"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "my-terraform-state-lock"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }
}


terraform {
  backend "s3" {
    bucket         = "test"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = ""
    encrypt        = true
  }
}
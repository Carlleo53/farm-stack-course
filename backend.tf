terraform {
  backend "s3" {
    bucket         = "bestate_bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "statetf-locks"
  }
}
terraform {
  backend "s3" {
    bucket         = "carl-bestate-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "bestatetf-locks"
  }
}
terraform {
  backend "s3" {
    bucket = "terraform-backend-iquinho"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
  }
}

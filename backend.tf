# Standard S3 backend for Terraform state
# NOTE: backend configuration cannot use variables. Replace the placeholder values below
# with your real S3 bucket/key/region before running `terraform init`.


terraform {
  backend "s3" {
    bucket  = "sammyterraformbucket"          # replace with your S3 bucket name
    key     = "bankapp/terraform.tfstate"     # path/file inside the bucket
    region  = "us-east-1"                     # your AWS region
    encrypt = true
  }
}

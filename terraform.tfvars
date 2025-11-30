
# Project Info
aws_region   = "us-east-1"
project_name = "bank-app"
environment  = "dev"


# VPC
vpc_cidr        = "10.0.0.0/16"
azs             = ["us-east-1a", "us-east-1b"]

public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
infra_subnets   = ["10.0.11.0/28", "10.0.12.0/28"]


# EKS Node Group
eks_node_groups = {
  default = {
    desired_capacity = 2
    min_capacity     = 1
    max_capacity     = 3
    instance_type    = "t3.medium"
    key_name         = "cicd" # Replace with your EC2 key pair
  }
}


# RDS
rds_instance_type     = "db.t3.micro"
rds_allocated_storage = 20
rds_dbname            = "appdb"
rds_username          = "bank"
rds_password          = "sammy996"  # Replace with a secure password
rds_port              = 5432


# Route53 / Namecheap
namecheap_api_user = "your_api_user"
namecheap_api_key  = "your_api_key"
namecheap_username = "sammyosung"
namecheap_domain   = "samone.store"

#Lestencrpt email in Clusterissuer
letsencrypt_email  = "osung996@gmailcom"
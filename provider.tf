
terraform {
  required_version = ">=1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }

  backend "s3" {

    bucket = "tf-state-202407"
    key    = "ecr-ecs/terraform.tfstate"
    region = "eu-west-1"
    # dynamodb_table = "bedrock-tf-lock"
    use_lockfile = true




  }
}

provider "aws" {
  region = var.region
}

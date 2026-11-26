provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HudsonHarbor"
      Domain      = "hudsonharborid.com"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

provider "aws" {
  alias  = "mgmt"
  region = var.aws_region

}

provider "aws" {
  alias  = "sec_hub"
  region = var.aws_region
}
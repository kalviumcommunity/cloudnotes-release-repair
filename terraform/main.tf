terraform {
  required_version = ">= 1.4.0, < 2.0.0"
}

# Local configuration inventory only; not a GCP deployment.
module "service" {
  source           = "./modules/service"
  environment_name = var.environment
  image_tag        = var.image_tag
}

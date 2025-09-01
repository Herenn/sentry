# Main configuration for prod environment

# Example VPC module usage
module "vpc" {
  source = "../../modules/network"
  
  environment    = var.environment
  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  
  # Environment-specific overrides
  enable_nat_gateway = true
  enable_vpn_gateway = true
}

# Example compute module usage
module "compute" {
  source = "../../modules/compute"
  
  environment     = var.environment
  project_name    = var.project_name
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  
  # Environment-specific sizing
  instance_type = var.instance_type
  min_size      = var.min_size
  max_size      = var.max_size
}

# Example database module usage
module "database" {
  source = "../../modules/database"
  
  environment       = var.environment
  project_name      = var.project_name
  vpc_id           = module.vpc.vpc_id
  database_subnets = module.vpc.database_subnets
  
  # Environment-specific configuration
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  backup_retention  = 7
}
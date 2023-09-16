# Define and configure the 'network' module responsible for setting up the VPC, subnets, and routing.
#network moudle deployment
module "network" {
  source              = "./modules/network"  # Module source path.
  environment         = var.environment       # Pass the 'environment' variable to the module.
  vpc_cidr            = var.vpc_cidr          # Pass the 'vpc_cidr' variable to define VPC's CIDR block.
  public_subnet_cidr  = var.public_subnet_cidr # Pass the 'public_subnet_cidr' variable for public subnets.
  private_subnet_cidr = var.private_subnet_cidr# Pass the 'private_subnet_cidr' variable for private subnets.
  zones               = var.zones             # Pass the 'zones' variable for availability zones.
}


# Define and configure the 'compute' module responsible for provisioning compute resources like instances and security groups.
module "compute" {
  source = "./modules/compute"                 # Module source path.
  environment            = var.environment       # Pass the 'environment' variable for environment setup.
  vpc_id                 = module.network.vpc_id # Reference the VPC ID created by the 'network' module.
  key_pair_name          = var.key_pair_name    # Pass the 'key_pair_name' variable for SSH key pairs.
  private_subnet_ids     = module.network.private_subnet_ids # Reference private subnet IDs created by the 'network' module.
  public_subnet_ids      = module.network.public_subnet_ids   # Reference public subnet IDs created by the 'network' module.
  jenkins_machine_data   = var.jenkins_machine_data # Pass Jenkins machine configuration data.
  nexus_machine_data     = var.nexus_machine_data   # Pass Nexus machine configuration data.
  postgres_machine_data  = var.postgres_machine_data# Pass Postgres machine configuration data.
  sonarqube_machine_data = var.sonarqube_machine_data # Pass SonarQube machine configuration data.
  image_owner            = var.image_owner          # Pass the image owner for AWS AMIs.
  jumpbox_image_id       = var.jumpbox_image_id     # Pass the ID of the jumpbox image.
  jumpbox_name           = var.jumpbox_name         # Pass the name of the jumpbox instance.
  jumpbox_type           = var.jumpbox_type         # Pass the instance type for the jumpbox.
  postgres_user_script   = "./scripts/postgres-user-data.sh" # Specify the path to the Postgres user data script.
  sonar_user_script      = "./scripts/sonarqube-user-data.sh" # Specify the path to the SonarQube user data script.
  depends_on = [
    module.network  # Ensure the 'compute' module depends on the 'network' module's resources.
  ]
}



terraform {
  backend "local" {
    path = "../../phase2.tfstate"
  }
}
# Import the state from phase 1 and read the outputs
data "terraform_remote_state" "phase1" {
  backend = "local" 
  config = {
    path    = "../../phase1.tfstate"
  }
}

provider "nsxt" {
  host                  = var.host
  username              = var.nsxt_username
  password              = var.nsxt_password
  vmc_auth_mode         = "Bearer"
  vmc_token             = var.vmc_token
  allow_unverified_ssl  = true
  enforcement_point     = "vmc-enforcementpoint"
}

/*========================
Configure NSXT Networking
=========================*/

module "NSX" {
  source = "../NSX"

  Subnet12              = var.VMC_subnets["Subnet12"]
  Subnet12gw            = var.VMC_subnets["Subnet12gw"]
  Subnet12dhcp          = var.VMC_subnets["Subnet12dhcp"]
  Subnet13              = var.VMC_subnets["Subnet13"]
  Subnet13gw            = var.VMC_subnets["Subnet13gw"]
  Subnet13dhcp          = var.VMC_subnets["Subnet13dhcp"]
  Home_Gilles           = var.Home_Gilles
}


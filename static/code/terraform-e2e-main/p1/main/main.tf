
provider "aws" {
  region                = var.AWS_region
}

provider "vmc" {
  refresh_token         = var.vmc_token
  org_id                = var.my_org_id
}

terraform {
  backend "local" {
    path = "../../phase1.tfstate"
  }
}

/*================
Create AWS VPC
The VPC and subnets CIDR are set in "variables.tf" file
=================*/
module "VPCs" {
  source = "../VPCs"

  VPC_Att_cidr            = var.My_subnets["VPC_Attached"]
  Subnet10-Att_vpc        = var.My_subnets["Subnet10-Att_vpc"]
  Subnet20-Att_vpc        = var.My_subnets["Subnet20-Att_vpc"]

  region                  = var.AWS_region
}


/*================
Create EC2s
=================*/
module "EC2s" {
  source = "../EC2s"

  VM-AMI                  = var.VM_AMI
  WIN-AMI                 = var.Win_AMI
  key_pair                = var.key_pair

  // Attached VPC
  Subnet10-Att_vpc        = module.VPCs.Subnet10-Att_vpc_id
  Subnet10-Att_vpc-base   = var.My_subnets["Subnet10-Att_vpc"]
  SG-Att_vpc              = module.VPCs.SG-Att_vpc_id
}

/*================
Create SDDC
=================*/
module "SDDC" {
  source = "../SDDC"

  my_org_id             = var.my_org_id                   # ORG ID
  SDDC_Mngt             = var.My_subnets["SDDC_Mngt"]     # Management IP range
  SDDC_default          = var.My_subnets["SDDC_default"]  # Default SDDC Segment
  Att_vpc_subnet_id     = module.VPCs.Subnet10-Att_vpc_id # VPC attached subnet
  region                = var.AWS_region                  # AWS region
  AWS_account           = var.AWS_account                 # Your AWS account
}



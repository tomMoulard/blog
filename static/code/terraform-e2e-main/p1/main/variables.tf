/*================
REGIONS map:
==================
us-east-1         US East (N. Virginia)
us-east-2	      US East (Ohio)
us-west-1	      US West (N. California)
us-west-2	      US West (Oregon)
ca-central-1	  Canada (Central)

eu-west-1	      EU (Ireland)
eu-central-1	  EU (Frankfurt)
eu-west-2	      EU (London)
eu-west-3         EU (Paris)
eu-north-1        EU (stokholm)
eu-south-1        EU (Milan)

ap-northeast-1	  Asia Pacific (Tokyo)
ap-northeast-2	  Asia Pacific (Seoul)
ap-southeast-1	  Asia Pacific (Singapore)
ap-southeast-2	  Asia Pacific (Sydney)
ap-south-1	      Asia Pacific (Mumbai)
sa-east-1	      South America (São Paulo)
=================*/

variable "AWS_account"            {}
variable "vmc_token"              {}
variable "my_org_id"              {}

variable "AWS_region"         { default = "us-west-2"}
variable "key_pair"           { default = "my-oregon-key" }



/*================
Subnets IP ranges
=================*/
variable "My_subnets" {
  default = {

    SDDC_Mngt             = "10.10.0.0/23"
    SDDC_default          = "192.168.1.0/24"

    VPC_Attached          = "172.200.0.0/16"
    Subnet10-Att_vpc      = "172.200.10.0/24"
    Subnet20-Att_vpc      = "172.200.20.0/24"


  }
}

/*================
VM AMIs
=================*/

variable "VM_AMI"         { default = "ami-0528a5175983e7f28" } # Amazon Linux 2 AMI (HVM), SSD Volume Type - Oregon
variable "Win_AMI"        { default = "ami-0f18e475ccdc50e07" } # Microsoft Windows Server 2019 Base - Oregon





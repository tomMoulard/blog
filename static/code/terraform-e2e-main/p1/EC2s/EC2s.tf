

variable "key_pair"                 {}
variable "VM-AMI"                   {}
variable "WIN-AMI"                  {}

// Attached  VPC
variable "Subnet10-Att_vpc"         {}
variable "Subnet10-Att_vpc-base"    {}
variable "SG-Att_vpc"               {}



/*==========================
EC2 Instance in Attached VPC
===========================*/
resource "aws_network_interface" "VM1-Eth0" {
  subnet_id                     = var.Subnet10-Att_vpc
  security_groups               = [var.SG-Att_vpc]
  private_ips                   = [cidrhost(var.Subnet10-Att_vpc-base, 100)]
}
resource "aws_instance" "VM1" {
  ami                           = var.VM-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.VM1-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair
  user_data                     = file("${path.module}/user-data.ini")

  tags = {
    Name = "VM1-Attached VPC"
  }
}

/*==========================
Windows Instance in Attached VPC
===========================*/
resource "aws_network_interface" "WIN-Eth0" {
  subnet_id                     = var.Subnet10-Att_vpc
  security_groups               = [var.SG-Att_vpc]
  private_ips                   = [cidrhost(var.Subnet10-Att_vpc-base, 111)]
}
resource "aws_instance" "Windows" {
  ami                           = var.WIN-AMI
  instance_type                 = "t2.micro"
  network_interface {
    network_interface_id        = aws_network_interface.WIN-Eth0.id
    device_index                = 0
  }
  key_name                      = var.key_pair

  tags = {
    Name = "Windows-Attached VPC"
  }
}

/*================
Outputs variables for other modules to use
=================*/

output "Windows_IP"           {value = aws_instance.Windows.public_ip}


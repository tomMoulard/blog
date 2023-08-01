

variable "Subnet12"       {}
variable "Subnet12gw"     {}
variable "Subnet12dhcp"   {}
variable "Subnet13"       {}
variable "Subnet13gw"     {}
variable "Subnet13dhcp"   {}
variable "Home_Gilles"    {}




/*===========
Get SDDC data
============*/

data "nsxt_policy_transport_zone" "TZ" {
  display_name = "vmc-overlay-tz"
}

/*======================================
Scope for MGW is "/infra/labels/mgw"
Scope for CGW (applied to:) are:
  INTERNET: "/infra/labels/cgw-public"
  DX:       "/infra/labels/cgw-direct-connect"
  VPN:      "/infra/labels/cgw-vpn"
  VPC:      "/infra/labels/cgw-cross-vpc"
  ALL:      "/infra/labels/cgw-all"

T0 groups
---------
Connected VPC:    "/infra/tier-0s/vmc/groups/connected_vpc",
S3 Prefixes:      "/infra/tier-0s/vmc/groups/s3_prefixes",
Direct Connect:   "/infra/tier-0s/vmc/groups/directConnect_prefixes"

========================================*/

/*========
MGW rules
=========*/
resource "nsxt_policy_predefined_gateway_policy" "mgw" {
  lifecycle { prevent_destroy = true }
  path = "/infra/domains/mgw/gateway-policies/default"

  # New rules below . . 
  # Order in code below is order in GUI

  /* ESXi Provisioning Rules */
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/ESXI"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Provisioning"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/VMware_Remote_Console"
    ]
    source_groups         = []
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/VCENTER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Inbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = [
      "/infra/services/HTTPS",
      "/infra/services/ICMP-ALL",
      "/infra/services/SSO"
    ]
    source_groups         = [nsxt_policy_group.Home_Gilles.path]
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = ["/infra/domains/mgw/groups/NSX-MANAGER"]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "To NSX Manager"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = ["/infra/services/HTTPS"]
    source_groups         = []
    sources_excluded      = false
  }

//  # Default rules - need to be added here otherwise they will be removed on first terraform apply
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "ESXi Outbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = []
    source_groups         = ["/infra/domains/mgw/groups/ESXI"]
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "vCenter Outbound"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/mgw"]
    services              = []
    source_groups         = ["/infra/domains/mgw/groups/VCENTER"]
    sources_excluded = false
  }
}

/*========
CGW rules
=========*/

resource "nsxt_policy_predefined_gateway_policy" "cgw" {
  lifecycle { prevent_destroy = true }
  path = "/infra/domains/cgw/gateway-policies/default"

  # New rules below . . 
  # Order in code below is order in GUI
#  rule {
#    action = "ALLOW"
#    destination_groups    = ["/infra/tier-0s/vmc/groups/deployment_group_vpc_prefixes"]
#    destinations_excluded = false
#    direction             = "IN_OUT"
#    disabled              = false
#    display_name          = "to vTGW VPCs"
#    ip_version            = "IPV4_IPV6"
#    logged                = false
#    profiles              = []
#    scope                 = ["/infra/labels/cgw-direct-connect"]
#    services              = []
#    source_groups         = []
#    sources_excluded      = false
#  }
#  rule {
#    action = "ALLOW"
#    destination_groups    = []
#    destinations_excluded = false
#    direction             = "IN_OUT"
#    disabled              = false
#    display_name          = "from vTGW VPCs"
#    ip_version            = "IPV4_IPV6"
#    logged                = false
#    profiles              = []
#    scope                 = ["/infra/labels/cgw-direct-connect"]
#    services              = []
#    source_groups         = ["/infra/tier-0s/vmc/groups/deployment_group_vpc_prefixes"]
#    sources_excluded      = false
#  }
  rule {
    action = "ALLOW"
    destination_groups    = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "VMC to AWS"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services              = []
    source_groups         = []
    sources_excluded      = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "AWS to VMC"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-cross-vpc"]
    services              = []
    source_groups         = [
      "/infra/tier-0s/vmc/groups/connected_vpc",
      "/infra/tier-0s/vmc/groups/s3_prefixes"
    ]
    sources_excluded = false
  }
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Internet out"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-public"]
    services              = []
    source_groups         = [
      nsxt_policy_group.group12.path,
      nsxt_policy_group.group13.path
      ]
    sources_excluded = false
  }
  //  # Default rules - need to be added here otherwise they will be removed on first terraform apply
  rule {
    action = "ALLOW"
    destination_groups    = []
    destinations_excluded = false
    direction             = "IN_OUT"
    disabled              = false
    display_name          = "Default VTI Rule"
    ip_version            = "IPV4_IPV6"
    logged                = false
    profiles              = []
    scope                 = ["/infra/labels/cgw-vpn"]
    services              = []
    source_groups         = []
    sources_excluded = false
  }
}


/*==============
Create segments
===============*/

resource "nsxt_policy_fixed_segment" "seg12" {
  //try resource "nsxt_policy_fixed_segment" "seg12" {
  display_name        = "seg12"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr              = var.Subnet12gw
    dhcp_ranges       = [var.Subnet12dhcp]
  }
}
resource "nsxt_policy_fixed_segment" "seg13" {
  display_name        = "seg13"
  description         = "Terraform provisioned Segment"
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
  subnet {
    cidr = var.Subnet13gw
    dhcp_ranges = [var.Subnet13dhcp]
  }
}


/*==============
scaling test
===============*/
//variable "counter" {default = 1}
//resource "nsxt_policy_segment" "scale-test" {
//  count               = var.counter
//  display_name        = "scale-test-${count.index + 1}"
//  description         = "Terraform provisioned Segment"
//  connectivity_path   = "/infra/tier-1s/cgw"
//  transport_zone_path = data.nsxt_policy_transport_zone.TZ.path
//  subnet {
//    cidr              = "20.0.${count.index + 1}.1/24"
//  }
//}

/*===================
Create Network Groups
====================*/

resource "nsxt_policy_group" "group12" {
  display_name = "tf-group12"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet12]
    }
  }
}
resource "nsxt_policy_group" "group13" {
  display_name = "tf-group13"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    ipaddress_expression {
      ip_addresses = [var.Subnet13]
    }
  }
}

resource "nsxt_policy_group" "Home_Gilles" {
  display_name = "Home_Gilles"
  description  = "Terraform provisioned Group"
  domain       = "mgw"
  criteria {
    ipaddress_expression {
      ip_addresses = var.Home_Gilles
    }
  }
}

/*=====================================
Create Security Group based on NSX Tags
======================================*/
resource "nsxt_policy_group" "Blue_VMs" {
  display_name = "Blue_VMs"
  description = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = "Blue|NSX_tag"
    }
  }
}

resource "nsxt_policy_group" "Red_VMs" {
  display_name = "Red_VMs"
  description  = "Terraform provisioned Group"
  domain       = "cgw"
  criteria {
    condition {
      key = "Tag"
      member_type = "VirtualMachine"
      operator = "EQUALS"
      value = "Red|NSX_tag"
    }
  }
}

/*=====================================
Create DFW rules
======================================*/
resource "nsxt_policy_security_policy" "Colors" {
  display_name = "Colors"
  description = "Terraform provisioned Security Policy"
  category = "Application"
  domain = "cgw"
  locked = false
  stateful = true
  tcp_strict = false

  rule {
    display_name = "Blue2Red"
    source_groups = [
      nsxt_policy_group.Blue_VMs.path]
    destination_groups = [
      nsxt_policy_group.Red_VMs.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
  rule {
    display_name = "Red2Blue"
    source_groups = [
      nsxt_policy_group.Red_VMs.path]
    destination_groups = [
      nsxt_policy_group.Blue_VMs.path]
    action = "DROP"
    services = ["/infra/services/ICMP-ALL"]
    logged = true
  }
}



output "segment12_name"     {value = nsxt_policy_fixed_segment.seg12.display_name}
output "segment13_name"     {value = nsxt_policy_fixed_segment.seg13.display_name}



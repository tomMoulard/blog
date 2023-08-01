

variable "data_center"        {}
variable "cluster"            {}
variable "workload_datastore" {}
variable "compute_pool"       {}

variable "Subnet12_name"      {}
variable "Subnet13_name"      {}
variable "subnet12"           {}
variable "subnet13"           {}

variable "demo_count"         { default = 3 }


/*====================================
SDDC data
====================================*/

data "vsphere_datacenter" "dc" {
  name          = var.data_center
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = var.workload_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_resource_pool" "pool" {
  name          = var.compute_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network12" {
  name          = var.Subnet12_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network13" {
  name          = var.Subnet13_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*=================================================================
create S3 Content  Lib
==================================================================*/

resource "vsphere_content_library" "S3CL" {
  name            = "S3CL"
  storage_backing = [data.vsphere_datastore.datastore.id]
  description     = "AWS S3 Content Library"

  subscription {
    subscription_url = "https://s3.eu-central-1.amazonaws.com/s3-cl-frankfurt/lib.json"
    authentication_method = "NONE"
    automatic_sync = false
    on_demand = true
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [vsphere_content_library.S3CL]
  create_duration = "30s"
}

data "vsphere_content_library_item" "blue" {
  depends_on = [time_sleep.wait_30_seconds]
  name       = "blue"
  library_id = vsphere_content_library.S3CL.id
  type = "OVA"
}
/*=================================================================
Clone  Blue VMs
==================================================================*/
resource "vsphere_virtual_machine" "Blue" {
  lifecycle {
    ignore_changes = [annotation]
  }
  count             = var.demo_count
  name              = "Blue-VM-${count.index + 1}"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  folder            = "Workloads"

  num_cpus = 2
  memory   = 1024
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network12.id
  }
  disk {
    label = "disk0"
    size  = 20
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.blue.id
    customize {
      linux_options {
        host_name = "Photon"
        domain    = "vmc.local"
      }
      network_interface {
        ipv4_address = cidrhost(var.subnet12, 10 + count.index) #fixed IP address
        ipv4_netmask = 24
      }
      ipv4_gateway = cidrhost(var.subnet12, 1)
    }
  }
}
/*=================================================================
Clone  Red VMs
==================================================================*/
resource "vsphere_virtual_machine" "Red" {
  lifecycle {
    ignore_changes = [annotation]
  }
  count             = var.demo_count
  name              = "Red-VM-${count.index + 1}"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  datastore_id      = data.vsphere_datastore.datastore.id
  folder            = "Workloads"

  num_cpus = 2
  memory   = 1024
  guest_id = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network13.id
  }
  disk {
    label = "disk0"
    size  = 20
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_content_library_item.blue.id
    customize {
      linux_options {
        host_name = "Photon"
        domain    = "vmc.local"
      }
      network_interface {
        ipv4_address = cidrhost(var.subnet13, 10 + count.index) #fixed IP address
        ipv4_netmask = 24
      }
      ipv4_gateway = cidrhost(var.subnet13, 1)
    }
  }
}


/*=================================================================
Apply NSX tags to VMs
==================================================================*/
resource "nsxt_policy_vm_tags" "NSX_Blue_tag" {
  count = var.demo_count
  instance_id = vsphere_virtual_machine.Blue[count.index].id
  tag {
    tag   = "NSX_tag"
    scope = "Blue"
  }
}
resource "nsxt_policy_vm_tags" "NSX_Red_tag" {
  count = var.demo_count
  instance_id = vsphere_virtual_machine.Red[count.index].id
  tag {
    tag   = "NSX_tag"
    scope = "Red"
  }
}

/*=================================================================
Define vSphere tags
==================================================================*/
resource "vsphere_tag_category" "category" {
  name        = "ColoredVMs"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "tag" {
  name        = "vSphere_tag"
  category_id = vsphere_tag_category.category.id
  description = "Managed by Terraform"
}



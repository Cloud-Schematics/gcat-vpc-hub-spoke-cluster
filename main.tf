##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# Resource Group where VPC Resources Will Be Created
##############################################################################

data ibm_resource_group resource_group {
  name = var.resource_group
}

##############################################################################


##############################################################################
# Create Spoke VPC
##############################################################################

module spoke_vpc {
  source               = "./multizone-vpc"
  prefix               = "${var.prefix}-spoke"
  region               = var.region
  resource_group_id    = data.ibm_resource_group.resource_group.id
  subnets              = var.spoke_subnets
  # Rules earlier in the array apply first
  acl_rules            = flatten([
    local.cluster_rules,   # Add cluster rules
    local.allow_hub_cidrs, # Allow hub CIDR traffic
    var.spoke_acl_rules    # Apply all other rules
  ])
}

##############################################################################


##############################################################################
# Create Hub VPC
##############################################################################

module hub_vpc {
  source               = "./multizone-vpc"
  prefix               = "${var.prefix}-hub"
  region               = var.region
  resource_group_id    = data.ibm_resource_group.resource_group.id
  subnets              = var.hub_subnets
  # Rules earlier in the array apply first
  acl_rules            = flatten([
    local.allow_spoke_cidrs, # Allow spoke CIDR traffic
    var.hub_acl_rules        # Apply all other rules
  ])
  use_public_gateways  = var.hub_use_public_gateways
}

##############################################################################


##############################################################################
# COS Instance
##############################################################################

resource ibm_resource_instance cos {
  name              = "${var.prefix}-cos"
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  resource_group_id = data.ibm_resource_group.resource_group.id

  parameters = {
    service-endpoints = "private"
  }

  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }

}

##############################################################################


##############################################################################
# Create ROKS Cluster
##############################################################################

module roks_cluster {
  source            = "./cluster"
  # Account Variables
  prefix            = var.prefix
  region            = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  # VPC Variables
  vpc_id            = module.spoke_vpc.vpc_id
  subnets           = module.spoke_vpc.subnet_zone_list
  # Cluster Variables
  machine_type      = var.machine_type
  workers_per_zone  = var.workers_per_zone
  entitlement       = var.entitlement
  kube_version      = var.kube_version
  tags              = var.tags
  worker_pools      = var.worker_pools
  cos_id            = ibm_resource_instance.cos.id
}

##############################################################################


##############################################################################
# SSH key for creating VSI
##############################################################################

resource ibm_is_ssh_key ssh_key {
  name       = "${var.prefix}-ssh-key"
  public_key = var.ssh_public_key
}

##############################################################################



##############################################################################
# Create Bastion VSI
##############################################################################

module bastion_vsi {
    source                                = "./bastion_vsi"
    # Account Variables
    ibmcloud_api_key                      = var.ibmcloud_api_key
    prefix                                = var.prefix
    region                                = var.region
    resource_group                        = var.resource_group
    resource_group_id                     = data.ibm_resource_group.resource_group.id
    # VPC Variables
    vpc_id                                = module.hub_vpc.vpc_id
    proxy_subnet                          = module.hub_vpc.subnet_zone_list[0]
    ssh_key_id                            = ibm_is_ssh_key.ssh_key.id
    # VSI Variables
    linux_vsi_image                       = var.linux_vsi_image
    linux_vsi_machine_type                = var.linux_vsi_machine_type
    windows_vsi_image                     = var.windows_vsi_image
    windows_vsi_machine_type              = var.windows_vsi_machine_type
    # Cluster Variables
    cluster_name                          = module.roks_cluster.name
    cluster_id                            = module.roks_cluster.id
    cluster_private_service_endpoint_port = module.roks_cluster.private_service_endpoint_port
    cidr_block_string                     = join(",",module.spoke_vpc.subnet_zone_list.*.cidr)
}

##############################################################################
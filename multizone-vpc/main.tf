##############################################################################
# Create a VPC
##############################################################################

resource ibm_is_vpc vpc {
  name           = "${var.prefix}-vpc"
  resource_group = var.resource_group_id
  classic_access = var.classic_access
}

##############################################################################


##############################################################################
# Public Gateways (Optional)
##############################################################################

locals {
  # create object that only contains gateways that will be created
  gateway_object = {
    for zone in keys(var.use_public_gateways):
      zone => "${var.region}-${index(keys(var.use_public_gateways), zone) + 1}" if var.use_public_gateways[zone]
  }
}

resource ibm_is_public_gateway gateway {
  for_each       = local.gateway_object
  name           = "${var.prefix}-public-gateway-${each.key}"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  zone           = each.value
}

##############################################################################


##############################################################################
# Multizone subnets
##############################################################################

locals {
  # Object to reference gateways
  public_gateways = {
    for zone in ["zone-1", "zone-2", "zone-3"]:
    # If gateway is created, set to id, otherwise set to empty string
    zone => contains(keys(local.gateway_object), zone) ? ibm_is_public_gateway.gateway[zone].id : ""
  }
}

module subnets {
  source            = "./subnet" 
  region            = var.region 
  prefix            = var.prefix                  
  acl_id            = ibm_is_network_acl.multizone_acl.id
  subnets           = var.subnets
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  public_gateways   = local.public_gateways
}

##############################################################################
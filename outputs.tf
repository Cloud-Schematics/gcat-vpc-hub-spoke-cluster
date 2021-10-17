##############################################################################
# Spoke VPC Outputs
##############################################################################

output spoke_vpc_id {
  description = "ID of VPC created"
  value       = module.spoke_vpc.vpc_id
}

output spoke_vpc_crn {
  description = "CRN of VPC"
  value       = module.spoke_vpc.vpc_crn
}

output spoke_acl_id {
  description = "ID of ACL created for subnets"
  value       = module.spoke_vpc.acl_id
}

output spoke_public_gateways {
  description = "Public gateways created"
  value       = module.spoke_vpc.public_gateways
}

output spoke_subnet_ids {
  description = "The IDs of the subnets"
  value       = module.spoke_vpc.subnet_ids
}

output spoke_subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.spoke_vpc.subnet_detail_list
}

output spoke_subnet_zone_list {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.spoke_vpc.subnet_zone_list
}

##############################################################################


##############################################################################
# Hub VPC Outputs
##############################################################################

output hub_vpc_id {
  description = "ID of VPC created"
  value       = module.hub_vpc.vpc_id
}

output hub_vpc_crn {
  description = "CRN of VPC"
  value       = module.hub_vpc.vpc_crn
}

output hub_acl_id {
  description = "ID of ACL created for subnets"
  value       = module.hub_vpc.acl_id
}

output hub_public_gateways {
  description = "Public gateways created"
  value       = module.hub_vpc.public_gateways
}

output hub_subnet_ids {
  description = "The IDs of the subnets"
  value       = module.hub_vpc.subnet_ids
}

output hub_subnet_detail_list {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value       = module.hub_vpc.subnet_detail_list
}

output hub_subnet_zone_list {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.hub_vpc.subnet_zone_list
}

##############################################################################


##############################################################################
# Cluster Outputs
##############################################################################

output cluster_id {
  description = "ID of cluster created"
  value       = module.roks_cluster.id
}

output cluster_name {
  description = "Name of cluster created"
  value       = module.roks_cluster.name
}

output cluster_private_service_endpoint_url {
    description = "URL For Cluster Private Service Endpoint"
    value       = module.roks_cluster.private_service_endpoint_url
}

output cluster_private_service_endpoint_port {
    description = "Port for Cluster private service endpoint"
    value       = module.roks_cluster.private_service_endpoint_port
}

##############################################################################


##############################################################################
# VSI Outputs
##############################################################################

output linux_vsi_info {
    description = "Information for the Linux VSI"
    value       = module.bastion_vsi.linux_vsi_info
}

output windows_vsi_info {
    description = "Information for the Windows Server VSI"
    value       = module.bastion_vsi.windows_vsi_info
}

##############################################################################
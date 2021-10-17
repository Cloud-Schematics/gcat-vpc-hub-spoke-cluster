##############################################################################
# Account variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
}

variable prefix {
  description = "A unique identifier need to provision resources. Must begin with a letter"
  type        = string
  default     = "asset-roks"
  
  validation  {
    error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string
}

variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

variable resource_group_id {
  description = "ID of resource group where all infrastructure will be provisioned"
  type        = string
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable vpc_id {
  description = "ID of VPC where VSI will be provisioned"
  type        = string
}

variable proxy_subnet {
  description = "An object containing the CIDR block, zone, and ID of the proxy subnet"
  type        = object({
    id   = string
    zone = string
  })
}

##############################################################################


##############################################################################
# VSI Variables
##############################################################################

variable ssh_key_id {
  description = "ID of SSH key to use when provisioning VSI"
}

##############################################################################


##############################################################################
# Linux VSI Variables
##############################################################################

variable linux_vsi_image {
  description = "Image name used for VSI. Run 'ibmcloud is images' to find available images in a region"
  type        = string
  default     = "ibm-centos-7-6-minimal-amd64-2"
}

variable linux_vsi_machine_type {
  description = "VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles"
  type        =  string
  default     = "bx2-8x32"
}

variable cluster_name {
  description = "Name of the cluster to connect to"
  type        = string
}

variable cluster_private_service_endpoint_port {
  description = "Port of the cluster private service endpoint"
}

variable cluster_id {
  description = "ID of the cluster. This is used to trigger the recreation and destruction of VSI"
  type        = string
}

variable cidr_block_string {
  description = "A string containing cluster subnet cidr blocks separated by commas"
  type        = string
}

##############################################################################


##############################################################################
# Windows VSI Variables
##############################################################################

variable windows_vsi_image {
  description = "Image name used for VSI. Run 'ibmcloud is images' to find available images in a region"
  type        = string
  default     = "ibm-windows-server-2012-full-standard-amd64-3"
}

variable windows_vsi_machine_type {
  description = "VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles"
  type        =  string
  default     = "bx2-8x32"
}

##############################################################################

##############################################################################
# Security Group Rules
##############################################################################

variable security_group_rules {
  description = "A list of security group rules to be added to the VSI security group"
  type        = list(
    object({
      name        = string
      direction   = string
      remote      = string
      tcp         = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp         = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp        = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )

  default = [
    {
      name      = "allow-inbound-ping"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      icmp      = {
        type = 8
      }
    },
    {
      name      = "allow-inbound-ssh"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp       = {
        port_min = 22
        port_max = 22
      }
    },
    {
        name      = "allow-all-outbound"
        direction = "outbound"
        remote    = "0.0.0.0/0"
    }
  ]

  validation {
    error_message = "Security group rules can only have one of `icmp`, `udp`, or `tcp`."
    condition     = length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.security_group_rules:
        # Return true if there is more than one of `icmp`, `udp`, or `tcp`
        true if length(
          [
            for type in ["tcp", "udp", "icmp"]:
            true if rule[type] != null
          ]
        ) > 1
      ])
    )) == 0 # Checks for length. If all fields all correct, array will be empty
  }  

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules:
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "Security group rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.security_group_rules:
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }
}

##############################################################################
##############################################################################
# Account Variables
# Copyright 2020 IBM
##############################################################################

# Comment this variable if running in schematics
variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
  sensitive   = true
}

# Comment out if not running in schematics
variable TF_VERSION {
 default     = "1.0"
 description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable prefix {
    description = "A unique identifier need to provision resources. Must begin with a letter"
    type        = string
    default     = "gcat-multizone"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
    }
}

variable region {
  description = "Region where VPC will be created"
  type        = string
  default     = "us-south"
}

variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "gcat-landing-zone-dev"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}

##############################################################################


##############################################################################
# Spoke VPC Variables
##############################################################################

variable spoke_subnets {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created."
  type        = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
  })
  default = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = false
      }
    ],
    zone-2 = [
      {
        name           = "subnet-b"
        cidr           = "10.20.10.0/24"
        public_gateway = false
      }
    ],
    zone-3 = [
      {
        name           = "subnet-c"
        cidr           = "10.30.10.0/24"
        public_gateway = false
      }
    ]
  }

  validation {
      error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
      condition     = keys(var.spoke_subnets)[0] == "zone-1" && keys(var.spoke_subnets)[1] == "zone-2" && keys(var.spoke_subnets)[2] == "zone-3"
  }
}

variable spoke_acl_rules {
  description = "Access control list rule set"
  type        = list(
    object({
      name        = string
      action      = string
      destination = string
      direction   = string
      source      = string
      tcp         = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
        })
      )
      udp         = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
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
  
  default     = [
    {
      name        = "deny-all-inbound"
      action      = "deny"
      direction   = "inbound"
      destination = "0.0.0.0/0"
      source      = "0.0.0.0/0"
    },
    {
      name        = "deny-all-outbound"
      action      = "deny"
      direction   = "outbound"
      destination = "0.0.0.0/0"
      source      = "0.0.0.0/0"
    }
  ]

  validation {
    error_message = "ACL rules can only have one of `icmp`, `udp`, or `tcp`."
    condition     = length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.spoke_acl_rules:
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
    error_message = "ACL rule actions can only be `allow` or `deny`."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.spoke_acl_rules:
        # Return false action is not valid
        false if !contains(["allow", "deny"], rule.action)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule direction can only be `inbound` or `outbound`."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.spoke_acl_rules:
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.spoke_acl_rules:
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }

}

##############################################################################



##############################################################################
# Hub VPC Variables
##############################################################################

variable hub_subnets {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created."
  type        = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
    }))
  })
  default = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.90.10.0/24"
        public_gateway = false
      }
    ],
    zone-2 = [],
    zone-3 = []
  }

  validation {
      error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
      condition     = keys(var.hub_subnets)[0] == "zone-1" && keys(var.hub_subnets)[1] == "zone-2" && keys(var.hub_subnets)[2] == "zone-3"
  }
}

variable hub_use_public_gateways {
  description = "Create a public gateway in any of the three zones with `true`."
  type        = object({
    zone-1 = optional(bool)
    zone-2 = optional(bool)
    zone-3 = optional(bool)
  })
  default     = {
    zone-1 = true
    zone-2 = true
    zone-3 = true
  }

  validation {
      error_message = "Keys for `use_public_gateways` must be in the order `zone-1`, `zone-2`, `zone-3`."
      condition     = keys(var.hub_use_public_gateways)[0] == "zone-1" && keys(var.hub_use_public_gateways)[1] == "zone-2" && keys(var.hub_use_public_gateways)[2] == "zone-3"
  }
}


variable hub_acl_rules {
  description = "Access control list rule set"
  type        = list(
    object({
      name        = string
      action      = string
      destination = string
      direction   = string
      source      = string
      tcp         = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
        })
      )
      udp         = optional(
        object({
          port_max        = optional(number)
          port_min        = optional(number)
          source_port_max = optional(number)
          source_port_min = optional(number)
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
  
  default     = [
    {
      name        = "allow-all-inbound"
      action      = "allow"
      direction   = "inbound"
      destination = "0.0.0.0/0"
      source      = "0.0.0.0/0"
    },
    {
      name        = "allow-all-outbound"
      action      = "allow"
      direction   = "outbound"
      destination = "0.0.0.0/0"
      source      = "0.0.0.0/0"
    }
  ]

  validation {
    error_message = "ACL rules can only have one of `icmp`, `udp`, or `tcp`."
    condition     = length(distinct(
      # Get flat list of results
      flatten([
        # Check through rules
        for rule in var.hub_acl_rules:
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
    error_message = "ACL rule actions can only be `allow` or `deny`."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.hub_acl_rules:
        # Return false action is not valid
        false if !contains(["allow", "deny"], rule.action)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule direction can only be `inbound` or `outbound`."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.hub_acl_rules:
        # Return false if direction is not valid
        false if !contains(["inbound", "outbound"], rule.direction)
      ])
    )) == 0
  }

  validation {
    error_message = "ACL rule names must match the regex pattern ^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$."
    condition     = length(distinct(
      flatten([
        # Check through rules
        for rule in var.hub_acl_rules:
        # Return false if direction is not valid
        false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", rule.name))
      ])
    )) == 0
  }

}

##############################################################################



##############################################################################
# Cluster Variables
##############################################################################

variable machine_type {
    description = "The flavor of VPC worker node to use for your cluster. Use `ibmcloud ks flavors` to find flavors for a region."
    type        = string
    default     = "bx2.4x16"
}

variable workers_per_zone {
    description = "Number of workers to provision in each subnet"
    type        = number
    default     = 2

    validation {
        error_message = "Each zone must contain at least 2 workers."
        condition     = var.workers_per_zone >= 2
    }
}

variable entitlement {
    description = "If you purchased an IBM Cloud Cloud Pak that includes an entitlement to run worker nodes that are installed with OpenShift Container Platform, enter entitlement to create your cluster with that entitlement so that you are not charged twice for the OpenShift license. Note that this option can be set only when you create the cluster. After the cluster is created, the cost for the OpenShift license occurred and you cannot disable this charge."
    type        = string
    default     = "cloud_pak"
}

variable kube_version {
    description = "Specify the Kubernetes version, including the major.minor version. To see available versions, run `ibmcloud ks versions`."
    type        = string
    default     = "4.7.30_openshift"

    validation {
        error_message = "To create a ROKS cluster, the kube version must include `openshift`."
        condition     = can(regex(".*openshift", var.kube_version))
    }
}

variable wait_till {
    description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
    type        = string
    default     = "IngressReady"

    validation {
        error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
        condition     = contains([
            "MasterNodeReady",
            "OneWorkerNodeReady",
            "IngressReady"
        ], var.wait_till)
    }
}

variable tags {
    description = "A list of tags to add to the cluster"
    type        = list(string)
    default     = []

    validation  {
        error_message = "Tags must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for name in var.tags:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
        ]) == 0
    }
}

variable worker_pools {
    description = "List of maps describing worker pools"

    type        = list(object({
        name        = string
        machine_type     = string
        workers_per_zone = number
    }))

    default     = [
      {
        name             = "dev"
        machine_type     = "cx2.8x16"
        workers_per_zone = 2
      },
      {
        name             = "test"
        machine_type     = "mx2.4x32"
        workers_per_zone = 2
      }
    ]

    validation  {
        error_message = "Worker pool names must match the regex `^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$`."
        condition     = length([
            for pool in var.worker_pools:
            false if !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", pool.name))
        ]) == 0
    }

    validation {
        error_message = "Worker pools cannot have duplicate names."
        condition     = length(distinct([
            for pool in var.worker_pools:
            pool.name
        ])) == length(var.worker_pools)
    }

    validation {
        error_message = "Worker pools must have at least two workers per zone."
        condition     = length([
            for pool in var.worker_pools:
            false if pool.workers_per_zone < 2
        ]) == 0
    }

}

##############################################################################



##############################################################################
# VSI Variables
##############################################################################

variable ssh_public_key {
  description = "ssh public key to use for vsi"
  type        = string
}

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
locals {
    # Add rules to allow cluster creation
    cluster_rules = [
        # Cluster Rules
        {
            name        = "roks-create-worker-nodes-inbound"
            action      = "allow"
            source      = "161.26.0.0/16"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-create-worker-nodes-outbound"
            action      = "allow"
            destination = "161.26.0.0/16"
            source      = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-nodes-to-service-inbound"
            action      = "allow"
            source      = "166.8.0.0/14"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        {
            name        = "roks-nodes-to-service-outbound"
            action      = "allow"
            destination = "166.8.0.0/14"
            source      = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = null
            udp         = null
            icmp        = null
        },
        # App Rules
        {
            name        = "allow-app-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 30000
                source_port_max = 32767
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-app-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 30000
                port_max        = 32767
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-lb-incoming-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "inbound"
            tcp         = {
                source_port_min = 1
                source_port_max = 65535
                port_min        = 443
                port_max        = 443
            }
            udp         = null
            icmp        = null
        },
        {
            name        = "allow-lb-outgoing-traffic-requests"
            action      = "allow"
            source      = "0.0.0.0/0"
            destination = "0.0.0.0/0"
            direction   = "outbound"
            tcp         = {
                port_min        = 1
                port_max        = 65535
                source_port_min = 443
                source_port_max = 443
            }
            udp         = null
            icmp        = null
        }
    ]
    

    # Rules to allow all traffic to and from spoke VPC CIDR blocks
    allow_spoke_cidrs = flatten([
        # For each zone 
        for zone in ["zone-1", "zone-2", "zone-3"]:
        [
            # For each subnet in that zone
            for subnet in var.spoke_subnets[zone]:
            # Create an array with rules to allow traffic to and from that subnet
            [
                { 
                      name        = "allow-inbound-${var.prefix}-spoke-${subnet.name}"
                      action      = "allow"
                      direction   = "inbound"
                      destination = "0.0.0.0/0"
                      source      = subnet.cidr
                      tcp         = null
                      udp         = null
                      icmp        = null
                },
                {
                      name        = "allow-outbound-${var.prefix}-spoke-${subnet.name}"
                      action      = "allow"
                      direction   = "outbound"
                      destination = subnet.cidr
                      source      = "0.0.0.0/0"
                      tcp         = null
                      udp         = null
                      icmp        = null
                }
            ]
        ]
    ])

    # Rules to allow all traffic to and from hub VPC CIDR blocks
    allow_hub_cidrs = flatten([
        # For each zone
        for zone in ["zone-1", "zone-2", "zone-3"]:
        [
            # For each subnet in that zone
            for subnet in var.spoke_subnets[zone]:
            [
                # Create a rule to allow both inbount and outbound traffic
                { 
                      name        = "allow-inbound-${var.prefix}-hub-${subnet.name}"
                      action      = "allow"
                      direction   = "inbound"
                      destination = "0.0.0.0/0"
                      source      = subnet.cidr
                      tcp         = null
                      udp         = null
                      icmp        = null
                },
                {
                      name        = "allow-outbound-${var.prefix}-hub-${subnet.name}"
                      action      = "allow"
                      direction   = "outbound"
                      destination = subnet.cidr
                      source      = "0.0.0.0/0"
                      tcp         = null
                      udp         = null
                      icmp        = null
                }
            ]
        ]
    ])
}
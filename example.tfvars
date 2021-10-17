ibmcloud_api_key=""
TF_VERSION="1.0"
prefix="gcat-multizone"
region="us-south"
resource_group="gcat-landing-zone-dev"
spoke_subnets={ zone-1 = [ { name = "subnet-a" cidr = "10.10.10.0/24" public_gateway = false } ], zone-2 = [ { name = "subnet-b" cidr = "10.20.10.0/24" public_gateway = false } ], zone-3 = [ { name = "subnet-c" cidr = "10.30.10.0/24" public_gateway = false } ] }
spoke_acl_rules=[ { name = "deny-all-inbound" action = "deny" direction = "inbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" }, { name = "deny-all-outbound" action = "deny" direction = "outbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" } ]
hub_subnets={ zone-1 = [ { name = "subnet-a" cidr = "10.90.10.0/24" public_gateway = false } ], zone-2 = [], zone-3 = []
hub_use_public_gateways={ zone-1 = true zone-2 = true zone-3 = true }
hub_acl_rules=[ { name = "allow-all-inbound" action = "allow" direction = "inbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" }, { name = "allow-all-outbound" action = "allow" direction = "outbound" destination = "0.0.0.0/0" source = "0.0.0.0/0" } ]
machine_type="bx2.4x16"
workers_per_zone=2
entitlement="cloud_pak"
kube_version="4.7.30_openshift"
wait_till="IngressReady"
tags=[]
worker_pools=[ { name = "dev" machine_type = "cx2.8x16" workers_per_zone = 2 }, { name = "test" machine_type = "mx2.4x32" workers_per_zone = 2 } ]
ssh_public_key=""
linux_vsi_image="ibm-centos-7-6-minimal-amd64-2"
linux_vsi_machine_type="bx2-8x32"
windows_vsi_image="ibm-windows-server-2012-full-standard-amd64-3"
windows_vsi_machine_type="bx2-8x32"
security_group_rules=[ { name = "allow-inbound-ping" direction = "inbound" remote = "0.0.0.0/0" icmp = { type = 8 } }, { name = "allow-inbound-ssh" direction = "inbound" remote = "0.0.0.0/0" tcp = { port_min = 22 port_max = 22 } }, { name = "allow-all-outbound" direction = "outbound" remote = "0.0.0.0/0" } ]

resource "mgc_network_security_groups" "swarm" {
  provider = mgc.sudeste
  name = "swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.swarm.id
}

resource "mgc_network_security_groups_rules" "allow_exporters" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 9000
  port_range_min    = 8000
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.swarm.id
}

resource "mgc_network_security_groups_rules" "allow_prometheus" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 9090
  port_range_min    = 9090
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.swarm.id
}
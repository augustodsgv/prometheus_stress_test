resource "mgc_network_security_groups" "prometheus_stress_test_swarm" {
  provider = mgc.sudeste
  name = "prometheus_stress_test_swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh_swarm" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prometheus_stress_test_swarm.id
}

resource "mgc_network_security_groups" "prometheus_node" {
  provider = mgc.sudeste
  name = "prometheus_node"
}

resource "mgc_network_security_groups_rules" "allow_ssh_node" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prometheus_node.id
}

resource "mgc_network_security_groups_rules" "allow_prometheus" {
  provider = mgc.sudeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 9000
  port_range_min    = 9000
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prometheus_node.id
}
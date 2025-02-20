resource "mgc_network_security_groups" "stress_test_tcc_guto_swarm" {
  provider = mgc.nordeste
  name = "stress_test_tcc_guto_swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh_swarm" {
  provider = mgc.nordeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.stress_test_tcc_guto_swarm.id
}

resource "mgc_network_security_groups_rules" "allow_exporters" {
  provider = mgc.nordeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 20000
  port_range_min    = 8000
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.stress_test_tcc_guto_swarm.id
}

resource "mgc_network_security_groups" "prometheus_node_tcc_guto" {
  provider = mgc.nordeste
  name = "prometheus_node_tcc_guto"
}

resource "mgc_network_security_groups_rules" "allow_ssh_node" {
  provider = mgc.nordeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prometheus_node_tcc_guto.id
}

resource "mgc_network_security_groups_rules" "allow_prometheus" {
  provider = mgc.nordeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 9090
  port_range_min    = 9090
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.prometheus_node_tcc_guto.id
}
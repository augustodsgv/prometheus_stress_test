terraform {
  required_providers {
    mgc = {
      source = "MagaluCloud/mgc"
      version = "0.32.2"
    }
  }
}

# SSH key
resource "mgc_ssh_keys" "swarm" {
  provider = mgc.nordeste
  key  = file(var.ssh_key_path)
  name = "swarm"
}

# Security group
resource "mgc_network_security_groups" "swarm" {
  provider = mgc.nordeste
  name = "swarm"
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  provider = mgc.nordeste
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
  provider = mgc.nordeste
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
  provider = mgc.nordeste
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 9090
  port_range_min    = 9090
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.swarm.id
}

# VMs
resource "mgc_virtual_machine_instances" "node" {
  provider = mgc.nordeste
  count = var.cluster_size
  name         = "node-${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.swarm.name
}

resource "mgc_network_public_ips" "node" {
  count = var.cluster_size
  provider = mgc.nordeste
  description = "Docker swarm node ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "node" {
  provider = mgc.nordeste
  count = var.cluster_size
  public_ip_id = mgc_network_public_ips.node[count.index].id
  interface_id = mgc_virtual_machine_instances.node[count.index].network_interfaces[0].id
}




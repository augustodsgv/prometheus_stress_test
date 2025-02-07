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
  provider = mgc.sudeste
  key  = file(var.ssh_key_path)
  name = "swarm"
}

# VMs
resource "mgc_virtual_machine_instances" "swarm_nodes" {
  provider = mgc.sudeste
  count = var.cluster_size
  name         = "swarm_nodes_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.swarm.name
}

resource "mgc_network_public_ips" "swarm_nodes" {
  count = var.cluster_size
  provider = mgc.sudeste
  description = "Docker swarm swarm_nodes ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "swarm_nodes" {
  provider = mgc.sudeste
  count = var.cluster_size
  public_ip_id = mgc_network_public_ips.swarm_nodes[count.index].id
  interface_id = mgc_virtual_machine_instances.swarm_nodes[count.index].network_interfaces[0].id
}
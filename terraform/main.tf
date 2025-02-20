terraform {
  required_providers {
    mgc = {
      source = "MagaluCloud/mgc"
      version = "0.32.2"
    }
  }
}

# SSH key
resource "mgc_ssh_keys" "stress_test_tcc_guto_key" {
  provider = mgc.nordeste
  key  = file(var.ssh_key_path)
  name = "stress_test_tcc_guto_key"
}

# Worker nodes
resource "mgc_virtual_machine_instances" "stress_test_tcc_guto_worker" {
  provider = mgc.nordeste
  count = var.worker_count
  name         = "stress_test_tcc_guto_worker_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.stress_test_tcc_guto_key.name
}

resource "mgc_network_public_ips" "stress_test_tcc_guto_worker" {
  count = var.worker_count
  provider = mgc.nordeste
  description = "Docker swarm stress_test_tcc_guto_worker ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "stress_test_tcc_guto_worker" {
  provider = mgc.nordeste
  count = var.worker_count
  public_ip_id = mgc_network_public_ips.stress_test_tcc_guto_worker[count.index].id
  interface_id = mgc_virtual_machine_instances.stress_test_tcc_guto_worker[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "stress_test_tcc_guto_worker" {
  provider = mgc.nordeste
  count = var.worker_count
  security_group_id = mgc_network_security_groups.stress_test_tcc_guto_swarm.id
  interface_id = mgc_virtual_machine_instances.stress_test_tcc_guto_worker[count.index].network_interfaces[0].id
}

# Manager nodes
resource "mgc_virtual_machine_instances" "stress_test_tcc_guto_manager" {
  provider = mgc.nordeste
  count = var.manager_count
  name         = "stress_test_tcc_guto_manager_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.stress_test_tcc_guto_key.name
}

resource "mgc_network_public_ips" "stress_test_tcc_guto_manager" {
  count = var.manager_count
  provider = mgc.nordeste
  description = "Docker swarm stress_test_tcc_guto_manager ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "stress_test_tcc_guto_manager" {
  provider = mgc.nordeste
  count = var.manager_count
  public_ip_id = mgc_network_public_ips.stress_test_tcc_guto_manager[count.index].id
  interface_id = mgc_virtual_machine_instances.stress_test_tcc_guto_manager[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "stress_test_tcc_guto_manager" {
  provider = mgc.nordeste
  count = var.manager_count
  security_group_id = mgc_network_security_groups.stress_test_tcc_guto_swarm.id
  interface_id = mgc_virtual_machine_instances.stress_test_tcc_guto_manager[count.index].network_interfaces[0].id
}

# # Prometheus
# resource "mgc_virtual_machine_instances" "prometheus_node_tcc_guto" {
#   provider = mgc.nordeste
#   name         = "prometheus_node_tcc_guto"
#   machine_type = var.prometheus_node_tcc_guto_machine_type
#   image        = var.machine_image
#   ssh_key_name = mgc_ssh_keys.stress_test_tcc_guto_key.name
# }

# resource "mgc_network_public_ips" "prometheus_node_tcc_guto" {
#   provider = mgc.nordeste
#   description = "Prometheus node"
#   vpc_id      = var.vpc_id
# }

# resource "mgc_network_public_ips_attach" "prometheus_node_tcc_guto" {
#   provider = mgc.nordeste
#   public_ip_id = mgc_network_public_ips.prometheus_node_tcc_guto.id
#   interface_id = mgc_virtual_machine_instances.prometheus_node_tcc_guto.network_interfaces[0].id
# }

# resource "mgc_network_security_groups_attach" "prometheus_node_tcc_guto" {
#   provider = mgc.nordeste
#   security_group_id = mgc_network_security_groups.prometheus_node_tcc_guto.id
#   interface_id = mgc_virtual_machine_instances.prometheus_node_tcc_guto.network_interfaces[0].id
# }
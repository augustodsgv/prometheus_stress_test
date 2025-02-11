terraform {
  required_providers {
    mgc = {
      source = "MagaluCloud/mgc"
      version = "0.32.2"
    }
  }
}

# SSH key
resource "mgc_ssh_keys" "prometheus_stress_test_key" {
  provider = mgc.sudeste
  key  = file(var.ssh_key_path)
  name = "prometheus_stress_test_key"
}

# Worker nodes
resource "mgc_virtual_machine_instances" "prometheus_stress_test_worker" {
  provider = mgc.sudeste
  count = var.worker_count
  name         = "prometheus_stress_test_worker_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.prometheus_stress_test_key.name
}

resource "mgc_network_public_ips" "prometheus_stress_test_worker" {
  count = var.worker_count
  provider = mgc.sudeste
  description = "Docker swarm prometheus_stress_test_worker ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "prometheus_stress_test_worker" {
  provider = mgc.sudeste
  count = var.worker_count
  public_ip_id = mgc_network_public_ips.prometheus_stress_test_worker[count.index].id
  interface_id = mgc_virtual_machine_instances.prometheus_stress_test_worker[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "prometheus_stress_test_worker" {
  provider = mgc.sudeste
  count = var.worker_count
  security_group_id = mgc_network_security_groups.prometheus_stress_test_swarm.id
  interface_id = mgc_virtual_machine_instances.prometheus_stress_test_worker[count.index].network_interfaces[0].id
}

# Manager nodes
resource "mgc_virtual_machine_instances" "prometheus_stress_test_manager" {
  provider = mgc.sudeste
  count = var.manager_count
  name         = "prometheus_stress_test_manager_${count.index}"
  machine_type = var.swarm_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.prometheus_stress_test_key.name
}

resource "mgc_network_public_ips" "prometheus_stress_test_manager" {
  count = var.manager_count
  provider = mgc.sudeste
  description = "Docker swarm prometheus_stress_test_manager ${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "prometheus_stress_test_manager" {
  provider = mgc.sudeste
  count = var.manager_count
  public_ip_id = mgc_network_public_ips.prometheus_stress_test_manager[count.index].id
  interface_id = mgc_virtual_machine_instances.prometheus_stress_test_manager[count.index].network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "prometheus_stress_test_manager" {
  provider = mgc.sudeste
  count = var.manager_count
  security_group_id = mgc_network_security_groups.prometheus_stress_test_swarm.id
  interface_id = mgc_virtual_machine_instances.prometheus_stress_test_manager[count.index].network_interfaces[0].id
}

# Prometheus
resource "mgc_virtual_machine_instances" "prometheus_node" {
  provider = mgc.sudeste
  name         = "prometheus_node"
  machine_type = var.prometheus_node_machine_type
  image        = var.machine_image
  ssh_key_name = mgc_ssh_keys.prometheus_stress_test_key.name
}

resource "mgc_network_public_ips" "prometheus_node" {
  provider = mgc.sudeste
  description = "Prometheus node"
  vpc_id      = var.vpc_id
}

resource "mgc_network_public_ips_attach" "prometheus_node" {
  provider = mgc.sudeste
  public_ip_id = mgc_network_public_ips.prometheus_node.id
  interface_id = mgc_virtual_machine_instances.prometheus_node.network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "prometheus_node" {
  provider = mgc.sudeste
  security_group_id = mgc_network_security_groups.prometheus_node.id
  interface_id = mgc_virtual_machine_instances.prometheus_node.network_interfaces[0].id
}
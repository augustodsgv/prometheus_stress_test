output "swarm_nodes_a_public_ip" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.swarm_nodes:
      idx => mgc_network_public_ips.swarm_nodes[idx].public_ip
  }
}
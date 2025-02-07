output "node_a_public_ip" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.node:
      idx => mgc_network_public_ips.node[idx].public_ip
  }
}
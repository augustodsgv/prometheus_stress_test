output "stress_test_tcc_guto_managers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.stress_test_tcc_guto_manager :
    "manager-${idx}" => {
      public_ip  = mgc_network_public_ips.stress_test_tcc_guto_manager[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

output "stress_test_tcc_guto_workers_ips" {
  value = {
    for idx, vm in mgc_virtual_machine_instances.stress_test_tcc_guto_worker :
    "worker-${idx}" => {
      public_ip  = mgc_network_public_ips.stress_test_tcc_guto_worker[idx].public_ip,
      private_ip = vm.network_interfaces[0].local_ipv4
    }
  }
}

# output "prometheus_node_tcc_guto_ips" {
#   value = {
#     public_ip  = mgc_network_public_ips.prometheus_node_tcc_guto,
#     private_ip = mgc_virtual_machine_instances.prometheus_node_tcc_guto.network_interfaces[0].local_ipv4
#   }
# }
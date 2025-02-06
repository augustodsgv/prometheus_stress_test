output "node_a_public_ip" {
  value = "VM public IP${mgc_network_public_ips.node_a.public_ip}"
}
output "zabbix-server" {
  value = "http://${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}/zabbix"
}
output "client" {
  value = google_compute_instance.vm_instance2.network_interface.0.access_config.0.nat_ip
}


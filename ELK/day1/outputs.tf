
output "kibana" {
  value = "http://${google_compute_instance.vm_elk.network_interface.0.access_config.0.nat_ip}:5601"
}

output "tomcat" {
  value = "http://${google_compute_instance.vm_tomcat.network_interface.0.access_config.0.nat_ip}:8080"
}
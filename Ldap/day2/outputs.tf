output "server" {
  value = "ssh centos@${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}
output "client" {
  value = "ssh my_user@${google_compute_instance.vm_instance2.network_interface.0.access_config.0.nat_ip} with key use -i path/to/private/key"
}

output "ldap-admin-application" {
  value = "http://${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

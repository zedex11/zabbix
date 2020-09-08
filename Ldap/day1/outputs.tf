output "for-ssh-connection" {
  value = "ssh centos@${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
}

output "ldap-admin-application" {
  value = "http://${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

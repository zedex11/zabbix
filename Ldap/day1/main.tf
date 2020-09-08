// export GOOGLE_CLOUD_KEYFILE_JSON=

provider "google" {
  project       = var.project
  region        = "us-central1"
  zone          = "us-central1-c"
}

output "ldap-admin-address" {
  value = "http://${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

resource "google_compute_instance" "vm_instance" {
  name         = "ldap-day1"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  provisioner "file" {
    source = "files.gz"
    destination = "/tmp/files.gz"
    connection {
      host = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "centos"
      private_key = file(var.enter_path_to_private_key)
      agent = "false"
    }
  }
  metadata = {
    ssh-keys = "centos:${file(var.enter_path_to_public_key)}"    
  }
  metadata_startup_script = templatefile("conf_script.sh", { 
    PASSWD = "${var.enter_ldap_admin_password}" })

  network_interface {
    network = "default"
    access_config {
    }
  }
}
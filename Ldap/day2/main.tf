// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance 
resource "google_compute_instance" "vm_instance" {
  name         = "ldap-day2-server"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  //uploading necessary files to the instance  
  provisioner "file" {
    source = "files.gz"
    destination = "/tmp/files.gz"
    connection {
      host = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
      type = "ssh"
      user = "centos"
      private_key = file(var.enter_path_to_private_key) //path to your own private key
      agent = "false"
    }
  }

  metadata = {
    ssh-keys = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }

  metadata_startup_script = templatefile("script_server.sh", { 
    PASSWD  = "${var.enter_ldap_admin_password}"  //  password that will be used to user login 
    PUB_KEY = "${var.public_key_for_user}" })  // ssh_public key for our user

  network_interface {
    network = "default"
    access_config {
    }
  }
}


locals {
  server_IP = google_compute_instance.vm_instance.network_interface.0.network_ip
}

// create client instance 
resource "google_compute_instance" "vm_instance2" {
  name         = "ldap-day2-client"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }
  
  metadata = {
    ssh-keys = "centos:${file(var.enter_path_to_public_key)}"   
  }
  metadata_startup_script = templatefile("script_client.sh", { 
    IP = "${local.server_IP}" })  //getting server IP

  network_interface {
    network = "default"
    access_config {
    }
  }
}
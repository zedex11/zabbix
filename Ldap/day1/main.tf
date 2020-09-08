// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance 
resource "google_compute_instance" "vm_instance" {
  name         = "ldap-day1"
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
      private_key = file(var.enter_path_to_private_key) //will ask to enter the path to your own private key
      agent = "false"
    }
  }

  metadata = {
    ssh-keys = "centos:${file(var.enter_path_to_public_key)}" //will ask to enter the path to your own public key   
  }
  metadata_startup_script = templatefile("conf_script.sh", { 
    PASSWD = "${var.enter_ldap_admin_password}" })  // will ask to enter the password that will be used to login

  network_interface {
    network = "default"
    access_config {
    }
  }
}
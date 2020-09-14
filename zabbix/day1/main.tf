// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance 
resource "google_compute_instance" "vm_instance" {
  name         = "zabbix-server"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }

  metadata_startup_script = templatefile("zabbix_server.sh", { 
    PASSWD  = "${var.mongo_db_password}" }) //  password that will be used to user login 
   

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
  name         = "zabbix-client"
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
  metadata_startup_script = templatefile("zabbix_client.sh", { 
    IP = "${local.server_IP}" })  //getting server IP

  network_interface {
    network = "default"
    access_config {
    }
  }
}

resource "google_compute_firewall" "zabbix" {
  name          = "zabbix"
  network       = "default"
  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] 
}
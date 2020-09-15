// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance zabbix-server
resource "google_compute_instance" "vm_instance" {
  name         = "zabbix-server"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
  metadata = {
    ssh-keys   = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }
  metadata_startup_script = templatefile("zabbix_server.sh", { 
    PASSWD     = "${var.mongo_db_password}" }) //  password that will be used for db 
  network_interface {
    network    = "default"
    access_config {
    }
  }
}


locals {
  server_IP = google_compute_instance.vm_instance.network_interface.0.network_ip
}

// create zabbix-client and tomcat
resource "google_compute_instance" "vm_instance2" {
  name         = "zabbix-client"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server","tomcat"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
  //upload application for tomcat
  provisioner "file" {
    source      = "clusterjsp.war"
    destination = "/tmp/clusterjsp.war"
    connection {
      host      = google_compute_instance.vm_instance2.network_interface.0.access_config.0.nat_ip
      type      = "ssh"
      user      = "centos"
      agent     = "false"
      private_key = file(var.enter_path_to_private_key)
    }
  }
  metadata      = {
    ssh-keys    = "centos:${file(var.enter_path_to_public_key)}"   
  }
  metadata_startup_script = templatefile("zabbix_client_and_tomcat.sh", { 
    IP          = "${local.server_IP}" })  //getting server IP
  network_interface {
    network     = "default"
    access_config {
    }
  }
}


//create Ldap server 
resource "google_compute_instance" "vm_instance3" {
  name          = "ldap-day2-server"
  machine_type  = "n1-standard-1"
  tags          = ["http-server", "https-server"]

  boot_disk {
    initialize_params {
      image     = "centos-cloud/centos-7"
    }
  }
  //uploading necessary files to the instance  
  provisioner "file" {
    source      = "files.gz"
    destination = "/tmp/files.gz"
    connection {
      host      = google_compute_instance.vm_instance3.network_interface.0.access_config.0.nat_ip
      type      = "ssh"
      user      = "centos"
      private_key = file(var.enter_path_to_private_key) //path to your own private key
      agent     = "false"
    }
  }
  metadata = {
    ssh-keys    = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }
  metadata_startup_script = templatefile("ldap_server.sh", { 
    PASSWD      = "${var.enter_ldap_admin_password}"  //  password that will be used to user login 
    PUB_KEY     = "${var.public_key_for_user}" })  // ssh_public key for our user
  network_interface {
    network     = "default"
    access_config {
    }
  }
}


// create firewall rule for tomcat
resource "google_compute_firewall" "tomcat" {
  name          = "tomcat"
  network       = "default"
  allow {
    protocol    = "tcp"
    ports       = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["tomcat"] 
}
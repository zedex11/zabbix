// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone           = "us-central1-c"
}

//create elk instance 
resource "google_compute_instance" "vm_elk" {
  name          = "elk-server"
  machine_type  = "n1-standard-1"
  tags          = ["http-server", "https-server", "elk"]

  boot_disk {
    initialize_params {
      image     = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys    = "${var.user_name}:${file(var.enter_path_to_public_key)}"
  }
  metadata_startup_script = file("elk_script.sh")

  network_interface {
    network     = "default"
    access_config {
    }
  }
}


//create tomcat instance 
resource "google_compute_instance" "vm_tomcat" {
  name          = "tomcat-server"
  machine_type  = "n1-standard-1"
  tags          = ["http-server", "https-server", "tomcat"]

  boot_disk {
    initialize_params {
      image     = "centos-cloud/centos-7"
    }
  }

  metadata = {
    ssh-keys    = "${var.user_name}:${file(var.enter_path_to_public_key)}"  
  }
  metadata_startup_script = file("tomcat_script.sh")

  network_interface {
    network     = "default"
    access_config {
    }
  }
}

// create firewall rules for elk
resource "google_compute_firewall" "kibana" {
  name          = "kibana"
  network       = "default"
  allow {
    protocol    = "tcp"
    ports       = ["5601"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["elk"] 
}

resource "google_compute_firewall" "elastic" {
  name          = "elastic"
  network       = "default"
  allow {
    protocol    = "tcp"
    ports       = ["9200"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["elk"] 
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
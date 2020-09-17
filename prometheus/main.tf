// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance grafana-prometheus
resource "google_compute_instance" "vm_instance" {
  name         = "prometheus"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server","grafana"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
  metadata = {
    ssh-keys   = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }
  metadata_startup_script = templatefile("prometheus_script.sh", { 
    IP_remote  = "${local.remote}" }) // getting IP remoute node-exporter instance
  network_interface {
    network    = "default"
    access_config {
    }
  }
}

locals {
  remote = google_compute_instance.vm_instance2.network_interface.0.network_ip
}

//create instance node-exporter
resource "google_compute_instance" "vm_instance2" {
  name         = "node-exporter"
  machine_type = "n1-standard-1"
  tags         = ["http-server", "https-server","exporter"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
  metadata = {
    ssh-keys   = "centos:${file(var.enter_path_to_public_key)}" // path to your own public key   
  }
  metadata_startup_script = file("node-exporter_script.sh")
  network_interface {
    network    = "default"
    access_config {
    }
  }
}


//firewall rule for grafana-prometheus 
resource "google_compute_firewall" "grafana-prometheus" {
  name           = "grafana-prometheus"
  network        = "default"
  allow {
    protocol     = "tcp"
    ports        = ["9090","9100","3000","9115"]
  }
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["grafana"]
}

//firewall rule for node-exporter
resource "google_compute_firewall" "node-exporter" {
  name           = "node-exporter"
  network        = "default"
  allow {
    protocol     = "tcp"
    ports        = ["9100"]
  }
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["exporter"]
}
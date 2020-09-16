// export GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credential/json/file

provider "google" {
  project       = var.project // project id
  region        = "us-central1"
  zone          = "us-central1-c"
}

//create instance datadog-client
resource "google_compute_instance" "vm_instance" {
  name         = "datadog-client"
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
  metadata_startup_script = templatefile("agent-script.sh", { 
    KEY        = "${var.api_key}" }) //  token to datadog 
  network_interface {
    network    = "default"
    access_config {
    }
  }
}
//firewall rule for all external connections 
resource "google_compute_firewall" "external" {
  name           = "external"
  network        = "default"
  allow {
    protocol     = "tcp"
    ports        = ["0-65535"]
  }
  source_ranges = ["0.0.0.0/0"]
}


// create custom monitor in datadog
provider "datadog" {
  api_key = var.api_key
  app_key = var.app_key
  api_url = var.api_url
}

resource "datadog_monitor" "monitor" {
  name               = "test"
  type               = "metric alert"
  message            = "Monitor triggered. Notify: zedex@tut.by"
  query              = "sum(last_5m):avg:datadog.agent.started{http-server} by {host}.as_count() < 1"
  depends_on         = [google_compute_instance.vm_instance]
}
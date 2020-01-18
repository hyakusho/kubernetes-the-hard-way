variable project {}
variable region { default = "asia-northeast1" }
variable availability_zones {
  type = list(string)
  default = [
    "asia-northeast1-a",
    "asia-northeast1-b",
    "asia-northeast1-c"
  ]
}
variable credential_file {}

terraform {
  required_version = "~> 0.12.18"
}

provider "google" {
  version = "~> 3.2"
  credentials = file("${var.credential_file}")
  project = var.project
  region = var.region
  zone = var.availability_zones[0]
}

resource "google_compute_network" "kubernetes_the_hard_way" {
  name = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "kubernetes" {
  name = "kubernetes"
  network = google_compute_network.kubernetes_the_hard_way.self_link
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "internal" {
  name = "kubernetes-the-hard-way-allow-internal"
  network = google_compute_network.kubernetes_the_hard_way.name
  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
}

resource "google_compute_firewall" "external" {
  name = "kubernetes-the-hard-way-allow-external"
  network = google_compute_network.kubernetes_the_hard_way.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = ["22", "6443"]
  }
}

resource "google_compute_address" "default" {
  name = "kubernetes-the-hard-way"
  region = var.region
}

resource "google_compute_instance" "controller" {
  count = 3

  name = format("controller-%d", count.index)
  boot_disk {
    initialize_params {
      size = 200
      type = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  can_ip_forward = true
  machine_type = "n1-standard-1"
  zone = var.availability_zones[count.index]
  network_interface {
    network = google_compute_network.kubernetes_the_hard_way.name
    subnetwork = google_compute_subnetwork.kubernetes.name
    network_ip = format("10.240.0.1%d", count.index)
    access_config {}
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
  tags = ["kubernetes-the-hard-way", "controller"]
}

resource "google_compute_instance" "worker" {
  count = 3

  name = format("worker-%d", count.index)
  boot_disk {
    initialize_params {
      size = 200
      type = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  can_ip_forward = true
  machine_type = "n1-standard-1"
  zone = var.availability_zones[count.index]
  network_interface {
    network = google_compute_network.kubernetes_the_hard_way.name
    subnetwork = google_compute_subnetwork.kubernetes.name
    network_ip = format("10.240.0.2%d", count.index)
    access_config {}
  }
  service_account {
    scopes = ["compute-rw", "storage-ro", "service-management", "service-control", "logging-write", "monitoring"]
  }
  tags = ["kubernetes-the-hard-way", "worker"]
  metadata = {
    pod-cidr = format("10.200.%d.0/24", count.index)
  }
}

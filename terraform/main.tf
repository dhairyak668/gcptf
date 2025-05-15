provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "custom_vpc" {
  name                    = "custom-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "custom-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.custom_vpc.id
}

resource "google_compute_firewall" "allow-http-https" {
  name    = "allow-http-https"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

resource "google_compute_firewall" "allow-flask-8080" {
  name    = "allow-flask-8080"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flask-server"]
}

resource "google_compute_instance" "flask_vm" {
  name         = "flask-vm"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.custom_vpc.id
    subnetwork = google_compute_subnetwork.custom_subnet.id
    access_config {} # gives it a public IP
  }

  metadata_startup_script = file("startup.sh")

  tags = [
    "http-server", 
    "https-server", 
    "flask-server",
    "ssh-server",
    "redeploy-${replace(timestamp(), "/[^0-9]/", "")}"
  ]

  service_account {
    email  = google_service_account.gallery_sa.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    DB_USER     = "galleryuser"
    DB_PASSWORD = var.db_password
    DB_NAME     = "gallerydb"
    DB_HOST     = google_sql_database_instance.gallery_db_instance.public_ip_address
  }
}

resource "google_sql_database_instance" "gallery_db_instance" {
  name             = "gallery-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "gallery_database" {
  name     = "gallerydb"
  instance = google_sql_database_instance.gallery_db_instance.name
}

resource "google_sql_user" "gallery_user" {
  name     = "galleryuser"
  instance = google_sql_database_instance.gallery_db_instance.name
  password = var.db_password
}

resource "google_service_account" "gallery_sa" {
  account_id   = "gallery-service-account"
  display_name = "Gallery Service Account"
}

resource "google_project_iam_member" "sql_client_binding" {
  project = var.project_id
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.gallery_sa.email}"
}
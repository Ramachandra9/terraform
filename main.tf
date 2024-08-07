provider "google" {
  #credentials = file("extended-atrium-431809-d8-4819dde30623.json")
  project = "extended-atrium-431809-d8"
  region  = "us-central1" # or any other region you prefer
}

resource "google_compute_network" "vpc_network" {
  name = "my-vpc-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "my-java-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
    # Additional setup commands for your Java application
  EOT
}

resource "google_sql_database_instance" "default" {
  name             = "my-sql-instance"
  database_version = "POSTGRES_13"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "users" {
  name     = "db-user"
  instance = google_sql_database_instance.default.name
  password = "Test@2024"
}

resource "google_sql_database" "my_database" {
  name     = "my_database"
  instance = google_sql_database_instance.default.name
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

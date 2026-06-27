# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

# Cost estimation: https://cloud.google.com/products/calculator#id=0e3f1b7c-5d4a-4f8e-9c6e-2b1f3e5f6a7b
# $628.52 monthly (on-demand) for 1 VM with 16 vCPUs, 64GB RAM, and 500GB SSD persistent disk in eu-west4-a (Ireland) region.
# That's about $0.86 hourly

# Define the region and zone where the VM is hosted. Adjust these values as needed.
provider "google" {
  project = "your-project-id"
  region  = "eu-west4"
  zone    = "eu-west4-a"
}

# Create a non-preemptible VM instance with 16 vCPUs, 64GB RAM,a 500GB SSD persistent disk and accessible via static external IP address.
resource "google_compute_instance" "tableau-server" {
  name                      = "tableau-server-vm"
  machine_type              = "n2-custom-16-65536" # 16 vCPUs, 64GB RAM
  zone                      = "eu-west4-a"
  tags                      = ["tableau-server"]   # put VM behind a firewall rule that allows Tableau ports (80, 443, 8850)
  allow_stopping_for_update = true                 # allow the VM to be updated (e.g., resizing)

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20260517" # Ubuntu 24.04 LTS (Noble) - 64-bit
      size  = 500
      type  = "pd-ssd" # 500 GB SSD persistent disk
    }
    mode        = "READ_WRITE"
    auto_delete = true
    device_name = "tableau-server"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD" # standard provisioning model
    preemptible         = false      # non-preemptible
  }

  network_interface {
    access_config {
      nat_ip       = "8.234.129.89" # reserve a static external IP address for the VM
      network_tier = "PREMIUM"
    }
    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/your-project-id/regions/eu-west4/subnetworks/default"
  }
}

# Create a Firewall rule to allow Tableau ports and apply it to the VM using the "tableau-server" tag.
# Adjust source_ranges to restrict access to your office/VPN IP range for better security.
resource "google_compute_firewall" "tableau_firewall" {
  name    = "allow-tableau-ports"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8850"]
  }
  source_ranges = ["0.0.0.0/0"]       # Restrict this to your office/VPN IP range!
  target_tags   = ["tableau-server"]
}

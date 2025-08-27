# A dedicated VPC network for the GKE cluster to ensure isolation.
resource "google_compute_network" "azubi_vpc" {
  name                    = "azubi-vpc"
  auto_create_subnetworks = false
}

# A subnetwork within the VPC for the GKE cluster.
resource "google_compute_subnetwork" "azubi_subnet" {
  name          = "azubi-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.azubi_vpc.id
}

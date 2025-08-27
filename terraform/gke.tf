# GKE Cluster Definition
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to use a
  # separate 'google_container_node_pool' resource. So we create the smallest
  # possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.azubi_vpc.id
  subnetwork = google_compute_subnetwork.azubi_subnet.id
}

# Separate Node Pool for the GKE Cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-nodes"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  version    = google_container_cluster.primary.min_master_version

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  lifecycle {
    ignore_changes = [
      node_config,
    ]
  }
}

# Create a dedicated service account for the GKE nodes
resource "google_service_account" "gke_sa" {
  account_id   = "gke-azubi-sa"
  display_name = "GKE Node Service Account for Azubi"
}

# Grant the necessary roles to the service account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/monitoring.viewer",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
    "roles/stackdriver.resourceMetadata.writer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

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

  node_config {
    service_account = google_service_account.gke_sa.email
  }
}

# Separate Node Pool for the GKE Cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-nodes"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  version    = google_container_cluster.primary.min_master_version

  node_config {
    service_account = google_service_account.gke_sa.email
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

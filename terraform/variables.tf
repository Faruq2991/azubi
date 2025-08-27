variable "project_id" {
  description = "The Google Cloud project ID to deploy to."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "europe-west4"
}

variable "zone" {
  description = "The GCP zone to deploy resources in."
  type        = string
  default     = "europe-west4-a"
}

variable "cluster_name" {
  description = "The name for the GKE cluster."
  type        = string
  default     = "azubi-cluster"
}

variable "gke_num_nodes" {
  description = "The number of nodes for the GKE cluster."
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "The machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}

variable "backend_php_image" {
  description = "The full path to the backend PHP container image."
  type        = string
  default     = "europe-west4-docker.pkg.dev/azubi-470211/azubi-repo/azubi-php:latest"
}

variable "backend_nginx_image" {
  description = "The full path to the backend Nginx container image."
  type        = string
  default     = "europe-west4-docker.pkg.dev/azubi-470211/azubi-repo/azubi-nginx:latest"
}

variable "backend_composer_image" {
  description = "The full path to the backend Composer container image for initialization."
  type        = string
  default     = "europe-west4-docker.pkg.dev/azubi-470211/azubi-repo/azubi-composer:latest"
}

variable "frontend_image" {
  description = "The full path to the frontend container image in Artifact Registry."
  type        = string
  default     = "europe-west4-docker.pkg.dev/azubi-470211/azubi-repo/azubi-frontend:latest"
}

variable "laravel_env_content" {
  description = "The base64-encoded content of the backend's .env file."
  type        = string
  sensitive   = true
  # No default: pass via TF_VAR_laravel_env_content or -var
}

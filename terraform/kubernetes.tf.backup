# Create a dedicated namespace for the application
resource "kubernetes_namespace" "azubi_ns" {
  metadata {
    name = "azubi"
  }
}

# Secret for Laravel Environment variables
# IMPORTANT: The content is expected to be a base64 encoded string from your .env file.
# Run `export TF_VAR_laravel_env_content=$(base64 -w 0 back-end/.env)` before `terraform apply`.
resource "kubernetes_secret" "laravel_env" {
  metadata {
    name      = "laravel-env-secret"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
  }
  data = {
    ".env" = var.laravel_env_content
  }
  type = "Opaque"
}

# ConfigMap for the Nginx reverse proxy configuration
resource "kubernetes_config_map" "nginx_conf" {
  metadata {
    name      = "nginx-conf"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
  }
  data = {
    "default.conf" = <<-EOT
      server {
          listen 80;
          server_name localhost;
          root /var/www/html/public;

          index index.php index.html;

          location / {
              try_files $uri $uri/ /index.php?$query_string;
          }

          location ~ \.php$ {
              try_files $uri =404;
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass 127.0.0.1:9000;
              fastcgi_index index.php;
              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param PATH_INFO $fastcgi_path_info;
          }
      }
    EOT
  }
}

# --- Backend Deployment and Service ---

resource "kubernetes_deployment" "azubi_backend" {
  metadata {
    name      = "azubi-backend-deployment"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
    labels = {
      app = "azubi-backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "azubi-backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "azubi-backend"
        }
      }
      spec {
        # Init container copies baked app code from PHP image to shared emptyDir
        init_container {
          name    = "init-app-code"
          image   = var.backend_php_image
          command = ["sh", "-c", "cp -R /var/www/html/. /app-code"]
          volume_mount {
            name       = "app-code"
            mount_path = "/app-code"
          }
        }

        # Main application containers
        container {
          name  = "php-fpm"
          image = var.backend_php_image
          port {
            container_port = 9000
          }
          volume_mount {
            name      = "app-code"
            mount_path = "/var/www/html"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.laravel_env.metadata[0].name
            }
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.mysql_secret.metadata[0].name
            }
          }
        }

        container {
          name  = "nginx"
          image = var.backend_nginx_image
          port {
            container_port = 80
          }
          volume_mount {
            name      = "app-code"
            mount_path = "/var/www/html"
            read_only = true
          }
          volume_mount {
            name      = "nginx-config-volume"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path  = "default.conf"
          }
        }

        # Shared volumes
        volume {
          name = "app-code"
          empty_dir {}
        }
        volume {
          name = "nginx-config-volume"
          config_map {
            name = kubernetes_config_map.nginx_conf.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "azubi_backend_service" {
  metadata {
    name      = "azubi-backend-service"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.azubi_backend.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP" # Internal service
  }
}

# --- Frontend Deployment and Service ---

resource "kubernetes_deployment" "azubi_frontend" {
  metadata {
    name      = "azubi-frontend-deployment"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
    labels = {
      app = "azubi-frontend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "azubi-frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "azubi-frontend"
        }
      }
      spec {
        container {
          image = var.frontend_image
          name  = "azubi-frontend"
          port {
            container_port = 3000
          }
          env {
            name  = "NEXT_PUBLIC_API_URL"
            value = "http://${kubernetes_service.azubi_backend_service.metadata[0].name}.${kubernetes_namespace.azubi_ns.metadata[0].name}.svc.cluster.local:80"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "azubi_frontend_service" {
  metadata {
    name      = "azubi-frontend-service"
    namespace = kubernetes_namespace.azubi_ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.azubi_frontend.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer" # Exposes the service externally
  }
}

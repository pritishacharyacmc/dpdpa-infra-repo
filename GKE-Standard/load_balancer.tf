# load_balancer.tf

# 1. Reserve a global static IP address
resource "google_compute_global_address" "lb_ip" {
  name = "${var.load_balancer_name}-ip"
}

# 2. Create a Cloud Armor security policy
resource "google_compute_security_policy" "armor_policy" {
  name = var.armor_policy_name
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow all rule"
  }
  # Add more rules as needed, e.g., for WAF
  # rule {
  #   action   = "deny(403)"
  #   priority = 1000
  #   match {
  #     expr {
  #       expression = "request.path.matches('/admin')"
  #     }
  #   }
  #   description = "Block access to admin pages"
  # }
}

# 3. Create a managed SSL certificate for your domain
resource "google_compute_managed_ssl_certificate" "lb_ssl_cert" {
  name    = "${var.load_balancer_name}-ssl-cert"
  managed {
    domains = [var.domain_name]
  }
}

# 4. Create the Backend Service
# This will be attached to the NEG created by our Kubernetes Service
resource "google_compute_backend_service" "backend_service" {
  name                            = "${var.load_balancer_name}-backend"
  protocol                        = "HTTP"
  port_name                       = "http"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  security_policy                 = google_compute_security_policy.armor_policy.self_link
  
  backend {
    group = google_compute_region_network_endpoint_group.gke_neg.self_link
    balancing_mode               = "RATE"
    max_rate_per_endpoint        = 100
  }

  health_checks = [google_compute_health_check.http_health_check.self_link]
}

# Health Check for the Backend Service
resource "google_compute_health_check" "http_health_check" {
    name = "${var.load_balancer_name}-hc"
    http_health_check {
        port = 80
        request_path = "/"
    }
}


# This data source finds the NEG created by the Kubernetes service annotation.
# The service must be created in Kubernetes before this can be found.
data "google_compute_region_network_endpoint_group" "gke_neg" {
  # This assumes you apply the Kubernetes YAML first or run terraform in two steps.
  name   = var.gke_neg_name
  region = var.region
}

# 5. Create the URL Map
resource "google_compute_url_map" "url_map" {
  name            = "${var.load_balancer_name}-url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

# 6. Create the Target HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.load_balancer_name}-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_ssl_cert.self_link]
}

# 7. Create the Global Forwarding Rule (the frontend)
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.load_balancer_name}-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "443"
  ip_address            = google_compute_global_address.lb_ip.address
  target                = google_compute_target_https_proxy.https_proxy.self_link
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_sql_database_instance" "main" {
  name             = "${var.project_name}-${var.env}-db"
  database_version = "POSTGRES_14"
  project          = var.project_name
  depends_on = [google_service_networking_connection.default]
  settings {
    tier            = "db-custom-1-3840" # vCPUs: 1 Memory: 3.75 GB
    disk_size       = "10"               # HDD storage: 10 GB
    disk_type       = "PD_HDD"
    disk_autoresize = false
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.peering_network.id
    }

  }
}

# Create a VPC network
resource "google_compute_network" "peering_network" {
  name = "peering-network-v1"
}

# Create an IP address
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc-v1"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.peering_network.id
}

# Create a private connection
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.peering_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# (Optional) Import or export custom routes
resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering = google_service_networking_connection.default.peering
  network = google_compute_network.peering_network.name

  import_custom_routes = true
  export_custom_routes = true
}
# Create a private connection

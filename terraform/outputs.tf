output "app_endpoint" {
  description = "Public IP of the Flask app VM"
  value       = google_compute_instance.flask_vm.network_interface[0].access_config[0].nat_ip
}

output "database_connection_name" {
  description = "finalprojectdb"
  value       = "steady-copilot-459615-f4:us-central1:finalprojectdb"
}

output "database_instance_ip" {
  description = "34.173.250.12"
  value       = "34.173.250.12"
}

output "vm_ip" {
  value = google_compute_instance.flask_vm.network_interface[0].access_config[0].nat_ip
}

output "db_connection_info" {
  value = {
    instance  = google_sql_database_instance.gallery_db_instance.name
    user      = google_sql_user.gallery_user.name
    password  = "securepassword123"
    db_name   = google_sql_database.gallery_database.name
    ip        = google_sql_database_instance.gallery_db_instance.public_ip_address
  }
}

output "db_info" {
  value = {
    db_instance = google_sql_database_instance.gallery_db_instance.name
    db_name     = google_sql_database.gallery_database.name
    db_user     = google_sql_user.gallery_user.name
    db_ip       = google_sql_database_instance.gallery_db_instance.public_ip_address
  }
  sensitive = true
}
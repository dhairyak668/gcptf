output "app_endpoint" {
  description = "Public IP of the Flask app VM"
  value       = google_compute_instance.flask_vm.network_interface[0].access_config[0].nat_ip
}

output "database_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.gallery_db_instance.connection_name
}

output "database_instance_ip" {
  description = "Public IP of the database instance"
  value       = google_sql_database_instance.gallery_db_instance.public_ip_address
}

output "vm_ip" {
  value = google_compute_instance.flask_vm.network_interface[0].access_config[0].nat_ip
}

output "db_connection_info" {
  value = {
    instance = google_sql_database_instance.gallery_db_instance.name
    user     = google_sql_user.gallery_user.name
    db_name  = google_sql_database.gallery_database.name
    ip       = google_sql_database_instance.gallery_db_instance.public_ip_address
  }
  # sensitive = true  # Uncomment if you want to hide this output
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
output "database_endpoint" {
  value = google_sql_database_instance.instance.connection_name
  description = "The connection name of the Cloud SQL instance."
}
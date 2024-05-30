resource "google_sql_database_instance" "instance" {
  name             = "my-sql-instance"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "public-connections"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.instance.name
  password = "password"
}

resource "google_project_iam_member" "gke_to_sql" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:terraform-sa@johnydev.iam.gserviceaccount.com"
}
# End-to-end DevOps | Python - MySQL App

<img src=imgs/cover.png>

This is a simple Python Flask application that performs CRUD operations on a MySQL database. The project contains scripts and Kubernetes manifests for deploying the Python application with MySQL Database on a GCP GKE cluster and Cloud SQL with an accompanying Container Registry repositories. The deployment includes setting up monitoring with Prometheus and Grafana, and a CI/CD pipeline.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- [Python](https://www.python.org/downloads/)
- [MySQL For Ubuntu](https://dev.mysql.com/downloads/repo/apt/) | [MySQL For Windows](https://dev.mysql.com/downloads/installer/)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) configured with appropriate permissions
- [Docker](https://docs.docker.com/engine/install/) installed and configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured to interact with your Kubernetes cluster
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
- [Helm](https://helm.sh/docs/intro/install/)
- [GitHub_CLI](https://github.com/cli/cli)
- [K9s](https://k9scli.io/topics/install/)
- [Beekeeper-Studio](https://www.beekeeperstudio.io/) `For Database Access`

## 1. Running the Application Locally

### Setting Up the Database

1. Start your MySQL server.
2. Create a new MySQL database for the application.
3. Update the database configuration in `app.py` to match your local MySQL settings:

   - DB_HOST: localhost
   - DB_USER: your MySQL username
   - DB_PASSWORD: your MySQL password
   - DB_DATABASE: your database name

4. Create a table in the database that will be used by your application
   ```sql
   CREATE TABLE tasks (
   id SERIAL PRIMARY KEY,
   title VARCHAR(255) NOT NULL,
   description TEXT,
   is_complete BOOLEAN DEFAULT false
   );
   ```

### Running the App

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

2. Install the dependencies:

   ```bash
   pip install -r requirements.txt
   ```

3. Run the application:

   ```bash
   python app.py
   ```

The application should now be running on `http://localhost:5000`.

## 2. Dockerizing the Application

### Building the Docker Image

1. Build the Docker image:

   ```bash
   docker build -t your-dockerhub-username/your-image-name:tag .
   ```

2. Run the Docker container:

   ```bash
   docker run -d -p 5000:5000 your-dockerhub-username/your-image-name:tag
   ```

## 3. Running the Application with Docker Compose

1. Update the `docker-compose.yml` file with your MySQL configuration.
2. Start the services:

   ```bash
   docker-compose up --build
   ```

## 4. Deploying to GKE (Google Kubernetes Engine)

```
./build.sh
```

## 6. Setting Up CI/CD Pipeline

1. Use GitHub Actions to set up the CI/CD pipeline.
2. Update the `.github/workflows` files as per your requirements for building, testing, and deploying your application.

## 7. Security Best Practices

Ensure that your database credentials and other sensitive information are not hard-coded in your application and added into github secrets using the following script:

```
./github_secrets.sh
```

Then you can push updates to your repository so the workflow can run.

## 8. Destroying the Infrastructure

In case you need to tear down the infrastructure and services that you have deployed, a script named `destroy.sh`. This script will:

- Create and download GCP Service Account key as JSON.
- Authenticate with Docker Registry.
- Delete GCR Docker Images.
- Destroy the GCP resources created by Terraform.

### Before you run

1. Open the `destroy.sh` script.
2. Ensure that the variables at the top of the script match your GCP and Kubernetes settings:

   ```bash
   project_id="PROJECT_ID"
   app_repo_name="todo-app-img"
   db_repo_name="todo-db-img"
   ```

### How to Run the Destroy Script

1. Save the script and make it executable:

   ```bash
   chmod +x destroy.sh
   ```

2. Run the script:

   ```bash
   ./destroy.sh
   ```

It is essential to verify that the script has completed successfully to ensure that all resources have been cleaned up and no unexpected costs are incurred.

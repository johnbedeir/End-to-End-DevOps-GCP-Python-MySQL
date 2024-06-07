#!/bin/bash

# Variables
project_id="johnydev"
service_account_email="terraform-sa@${project_id}.iam.gserviceaccount.com"
key_ids=$(gcloud iam service-accounts keys list --iam-account=$service_account_email --format="value(name)")
filename="gcp-credentials.json"
dbsecretname="db-password"
db_generated_password="$(gcloud secrets versions access latest --secret=cluster-1-cloudsql-secrets | jq -r '.password')"
app_namespace="todo-app"
app_svc="todo-app-service"
monitoring_namespace="monitoring"
alertmanager_svc="kube-prometheus-stack-alertmanager"
prometheus_svc="kube-prometheus-stack-prometheus"
grafana_svc="kube-prometheus-stack-grafana"
cd terraform
cloudsql_public_ip="$(terraform output -raw cloudsql_public_ip)"
cloudsecretname="$(terraform output -raw cloud_sql_name)"
zone=$(terraform output -json | jq -r .cluster_zone.value)
cluster_name="$(terraform output -raw cluster_name)"
dbendpoint="$(terraform output -raw public_ip)"
dbusername="$(terraform output -raw db_username)"
dbsecretusername="db-username"
cloudsql_endpoint="sql-endpoint"
app_repo_name="todo-app-img" # If you wanna change the repository name make sure you change it in the k8s/app.yml (Image name) 
db_repo_name="todo-db-img"
app_image_name="gcr.io/${project_id}/${app_repo_name}:latest"
db_image_name="gcr.io/${project_id}/${db_repo_name}:latest"
cd ..
# End Variables

# # update helm repos
# helm repo update

# # Google cloud authentication
# echo "--------------------GCP Login--------------------"
# gcloud auth login

# # Check if there are any keys to delete
# if [ -z "$key_ids" ]; then
#     echo "No keys found for service account: $service_account_email"
#     exit 0
# fi

# # Loop through each key ID and delete the key
# for key_id in $key_ids; do
#     echo "Deleting key $key_id for service account: $service_account_email"
#     gcloud iam service-accounts keys delete $key_id --iam-account=$service_account_email --quiet
# done

# # Get GCP credentials
# echo "--------------------Get Credentials--------------------"
# gcloud iam service-accounts keys create terraform/${filename} --iam-account ${service_account_email}

# # Build the infrastructure
# echo "--------------------Creating GKE--------------------"
# echo "--------------------Creating GCR--------------------"
# echo "--------------------Deploying Monitoring--------------------"
# cd terraform && \ 
# terraform init 
# terraform apply -auto-approve
# cd ..

# # Wait before updating kubeconfig
# echo "--------------------Wait before updating kubeconfig--------------------"
# sleep 30s

# # Update kubeconfig
# echo "--------------------Update Kubeconfig--------------------"
# gcloud container clusters get-credentials ${cluster_name} --zone ${zone} --project ${project_id}

# remove preious docker images
# echo "--------------------Remove Previous build--------------------"
# docker rmi -f ${app_image_name} || true
# docker rmi -f ${db_image_name} || true

# # build new docker image with new tag
# echo "--------------------Build new Image--------------------"
# docker build -t ${app_image_name} ./todo-app
# docker build -f k8s/Dockerfile.mysql -t ${db_image_name} k8s

# #GCR Authentication
# echo "--------------------Authenticate Docker with GCR--------------------"
# gcloud auth configure-docker

# # push the latest build to dockerhub
# echo "--------------------Pushing Docker Image--------------------"
# docker push ${app_image_name}
# docker push ${db_image_name}

# # create app_namespace
# echo "--------------------creating Namespace--------------------"
# kubectl create ns ${app_namespace} || true

# # Store the generated password in k8s secrets
# echo "--------------------Store the generated password in k8s secret--------------------"
# kubectl create secret generic ${cloudsql_endpoint} --from-literal=endpoint=${dbendpoint} --namespace=${app_namespace} || true
# kubectl create secret generic ${dbsecretusername} --from-literal=username=${dbusername} --namespace=${app_namespace} || true
# kubectl create secret generic ${dbsecretname} --from-literal=password=${db_generated_password} --namespace=${app_namespace} || true

# # Deploy the application
# echo "--------------------Deploy App--------------------"
# kubectl apply -n ${app_namespace} -f k8s

# # Wait for application to be deployed
# echo "--------------------Wait for all pods to be running--------------------"
# sleep 90s

echo ""
echo "Cloud_SQL: " ${cloudsql_public_ip}
echo ""
echo "App_URL:" $(kubectl get svc ${app_svc} -n ${app_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Alertmanager_URL:" $(kubectl get svc ${alertmanager_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Prometheus_URL:" $(kubectl get svc ${prometheus_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ""
echo "Grafana_URL: " $(kubectl get svc ${grafana_svc} -n ${monitoring_namespace} -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
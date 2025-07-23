## Django API Deployment Guide

This guide outlines how to deploy the Django API to Azure using Docker, Terraform, and Azure CLI. It is optimised for development on macOS (Apple Silicon) with containerised infrastructure managed via Terraform.


## 1. Prerequisites

> [!NOTE]
The guide assumes you are on an Apple Silicon (ARM) based architecture and deploy to an amd64 architecture CPU.  


Ensure the following tools are installed:

| Tool                | Version | Install Guide                                                                    |
| ------------------- | ------- |----------------------------------------------------------------------------------|
| **Terraform**       | ≥ 1.5   | `brew install terraform`                                                         |
| **Docker (Buildx)** | ≥ 24.0  | Install [Docker Desktop](https://www.docker.com) via GUI, **not** through `brew` |
| **Azure CLI**       | ≥ 2.59  | `brew install azure-cli`                                                         |
| **Python**          | 3.10+   | Use `pyenv` or install via `brew`                                                |
| **Git**             | Any     | `brew install git`                                                               |

Login to Azure once:

```bash
az login
az account set --subscription "<your-subscription-id>"
```
  
  
> [!WARNING]
Ensure you're authenticated before continuing.

## 2. Environment Setup

From the project root, ensure you have two properly configured files: `.env` for local development and `terraform.tfvars` for Azure deployment. 
These files should contain similar values and remain consistent.

```dotenv
SECRET_KEY=your-django-secret-key
DEBUG=0                              # (0 = False)
DJANGO_ALLOWED_HOSTS=django-api-<suffix>.azurewebsites.net

DB_ENGINE=django.contrib.gis.db.backends.postgis
DB_HOST=dialectdbsvr-<suffix>.postgres.database.azure.com
DB_PORT=5432
DB_NAME=dialectdb
DB_USER=djangoadmin@dialectdbsvr-<suffix>
DB_PASSWORD=your-db-password

AZURE_ACCOUNT_NAME=dialectstorage<suffix>
AZURE_ACCOUNT_KEY=your-storage-key
AZURE_CONTAINER=voice-recordings

SENTRY_DSN=https://<your-sentry-dsn>
```

## 3. Provision Infrastructure with Terraform

Navigate to the Terraform directory:

```bash
cd infra
terraform init
```

Preview the execution plan and specify the suffix (used across all resource names):

```bash
terraform plan -out=tfplan
```

If no errors, apply the plan:

```bash
terraform apply tfplan
```

Terraform will create:

* Azure Resource Group
* PostgreSQL Flexible Server
* Azure Storage Account
* Azure Container Registry (ACR)
* App Service Plan + Web App with container config

After apply, note the `suffix`, `ACR login server`, and `app service name`.

## 4. Build and Push Docker Image

Back in the root directory:

```bash
docker buildx build \
  --platform linux/amd64 \
  -f backend/docker/docker_files/Dockerfile \
  -t <ACR_LOGIN_SERVER>/django-api:latest \
  --push backend
```

Example:

```bash
docker buildx build \
  --platform linux/amd64 \
  -f backend/docker/docker_files/Dockerfile \
  -t djangoapiacra1f6.azurecr.io/django-api:latest \
  --push backend
```

## 5. Restart Azure Web App

```bash
az webapp restart \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```


## 6. Tail Logs for Debugging

```bash
az webapp log tail \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```

## 7. Verify Deployment

Visit your deployed app:

```
https://<app-service-name>.azurewebsites.net/
```

Admin interface:

```
https://<app-service-name>.azurewebsites.net/admin/
```

The container entrypoint ensures migrations, static collection, and superuser creation occur automatically on start.


## 8. Rebuild and Redeploy

After any code changes:

```bash
docker buildx build \
  --platform linux/amd64 \
  -f backend/docker/docker_files/Dockerfile \
  -t <ACR_LOGIN_SERVER>/django-api:latest \
  --push backend

az webapp restart \
  --resource-group <resource-group-name> \
  --name <app-service-name>
```


## 9. Troubleshooting

* **Gunicorn boot failure**: Check WSGI path. Must be `django_api.wsgi:application`, where `django_api` means your project name.

* **No module named `django-api`**: Use underscores in Python module names, not dashes.

* **No logs showing**: Enable logging in Azure:

  ```bash
  az webapp log config \
    --resource-group <rg> \
    --name <app-name> \
    --docker-container-logging filesystem
  ```

* **DB connection issues**: Ensure username is exactly what you provided in the `.env` file, such as `djangoadmin@<db_server_name>` and DB has public access if required (Terraform script sets up a vnet).


### Next Steps

- [ ] Set up a CI/CD automation build via GitHub issues, started a basic script at `.github/workflows/deploy.yml` but is unfinished.
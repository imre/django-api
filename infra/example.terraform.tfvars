#################################################################
#                                                               #
# Created by Imre Draskovits on 22 July 2025                    #
# Terraform v1.10.5                                             #
# on darwin_arm64                                               #
# + provider registry.terraform.io/hashicorp/azurerm v3.117.1   #
# + provider registry.terraform.io/hashicorp/random v3.7.2      #
#                                                               #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  #
#                                                               #
# DO NOT COMMIT THIS FILE TO THE REPOSITORY                     #
# THIS IS AN EXAMPLE FILE                                       #
#                                                               #
#################################################################

#  Core
location              = "UK South"
suffix                = "a1b2"                      # lock the imported suffix

resource_group_name   = "django-api"
acr_name              = "djangoapiacr"
app_service_plan_name = "django-api-plan"
web_app_name          = "django-api"

#  Database
postgresql_server_name = "django-api-db-a1b2"
db_admin_username      = "django-api-db-username"
db_admin_password      = "<STRONG-POSTGRES-PASSWORD>"   # sensitive
db_name                = "django-api-db"

#  Storage
storage_account_name   = "djangoapistorage"
storage_container_name = "django-api-folder-name"

#  Docker image / Container Registry
image_name = "django-api"
image_tag  = "latest"

#  Django application settings
secret_key  = "<DJANGO-SECRET-KEY>"               # sensitive
allowed_hosts = ".azurewebsites.net"
debug          = "0"                              # "0" for False, "1" for True

# Sentry
sentry_dsn = "https://<key>@o<org>.ingest.sentry.io/<project>"

# Django super‑user
django_superuser_username = "username"
django_superuser_email    = "email@example.com"
django_superuser_password = "<STRONG-SUPERUSER-PASSWORD>"   # sensitive

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

# Core
location              = "UK South"
project_name          = "django-api"
suffix                = ""                      # leave blank to let Terraform generate it

# Database credentials
db_admin_username     = "djangoadmin"
db_admin_password     = "YourPostgresPassword"

# Storage
storage_container_name = "django-api-storage"

# Docker image
image_tag = "latest"

# Django settings
secret_key                = "YourDjangoSecretKey"
django_superuser_username = "admin"
django_superuser_email    = "admin@example.com"
django_superuser_password = "YourSuperuserPassword"
allowed_hosts             = ".azurewebsites.net"
debug                     = "0"     # "0" for False, "1" for True

# Sentry (optional)
# sentry_dsn = "https://<key>@o<org>.ingest.sentry.io/<project>"

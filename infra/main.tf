# main.tf

#######################################
# 0.  Provider & random suffix       #
#######################################
provider "azurerm" {
  features {}
}

resource "random_id" "suffix" {
  byte_length = 2
}

# Compute all resource names from project_name + suffix
locals {
  suffix                = random_id.suffix.hex
  safe                  = replace(lower(var.project_name), "/-/", "")  # strip dashes
  rg_name               = "${var.project_name}-${local.suffix}"
  acr_name              = "${local.safe}acr${local.suffix}"
  storage_account_name  = "${local.safe}st${local.suffix}"
  service_plan_name     = "${var.project_name}-plan-${local.suffix}"
  web_app_name          = "${var.project_name}-${local.suffix}-web"
  db_server_name        = "${var.project_name}-dbsvr-${local.suffix}"
  db_name               = "${var.project_name}db${local.suffix}"
}

#################################
# 1.  Resource group            #
#################################
resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

#################################
# 2.  Container Registry (ACR)  #
#################################
resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = true
}

#################################
# 3.  Storage for media         #
#################################
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "media" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

#################################
# 4.  PostgreSQL Flexible       #
#################################
resource "azurerm_postgresql_flexible_server" "db" {
  name                            = local.db_server_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  version                         = "16"
  administrator_login             = var.db_admin_username
  administrator_password          = var.db_admin_password
  sku_name                        = "GP_Standard_D2s_v3"
  storage_mb                      = 32768
  backup_retention_days           = 7
  public_network_access_enabled   = false

  lifecycle { ignore_changes = [zone] }
}

resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = local.db_name
  server_id = azurerm_postgresql_flexible_server.db.id
  charset   = "UTF8"
}

#################################
# 5.  App Service Plan          #
#################################
resource "azurerm_service_plan" "plan" {
  name                = local.service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"
}

#################################
# 6.  Linux Web App             #
#################################
resource "azurerm_linux_web_app" "web" {
  name                = local.web_app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id
  https_only          = true

  identity { type = "SystemAssigned" }

  site_config {
    always_on = true

    application_stack {
      docker_image_name        = "${var.project_name}:${var.image_tag}"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }

    app_command_line = "gunicorn ${var.project_name}.wsgi:application --bind 0.0.0.0:8000 --workers 3"
  }

  app_settings = {
    SECRET_KEY                          = var.secret_key
    DEBUG                               = var.debug
    DJANGO_ALLOWED_HOSTS                = "${local.web_app_name}${var.allowed_hosts}"
    DB_ENGINE                           = "django.db.backends.postgresql" # or use `"django.contrib.gis.db.backends.postgis"` for GeoLocation support
    DB_NAME                             = local.db_name
    DB_USER                             = var.db_admin_username
    DB_PASSWORD                         = var.db_admin_password
    DB_HOST                             = azurerm_postgresql_flexible_server.db.fqdn
    DB_PORT                             = "5432"
    SENTRY_DSN                          = var.sentry_dsn
    DJANGO_SUPERUSER_EMAIL              = var.django_superuser_email
    DJANGO_SUPERUSER_USERNAME           = var.django_superuser_username
    DJANGO_SUPERUSER_PASSWORD           = var.django_superuser_password
    AZURE_ACCOUNT_NAME                  = azurerm_storage_account.storage.name
    AZURE_ACCOUNT_KEY                   = azurerm_storage_account.storage.primary_access_key
    AZURE_CONTAINER                     = var.storage_container_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "8000"
  }
}

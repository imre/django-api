# vnet.tf

# 1 – VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

# 2 – Subnet for Web App (delegated)
resource "azurerm_subnet" "app_subnet" {
  name                 = "app-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.1.0/24"]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# 3 – Subnet for Private Endpoints
resource "azurerm_subnet" "pe_subnet" {
  name                 = "pe-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.2.0/24"]
}

# 4 – Private Endpoint for Postgres
resource "azurerm_private_endpoint" "postgresql_pe" {
  name                = "${var.project_name}-dbsvr-pe-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "postgresql-psc"
    private_connection_resource_id = azurerm_postgresql_flexible_server.db.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }
}

# 5 – Private DNS zone & link
resource "azurerm_private_dns_zone" "postgresql_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "pe-zone-link"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_zone.name
}

resource "azurerm_private_dns_a_record" "postgresql_record" {
  name                = azurerm_postgresql_flexible_server.db.name
  zone_name           = azurerm_private_dns_zone.postgresql_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.postgresql_pe.private_service_connection[0].private_ip_address]
}

# 6 – Regional VNet integration
resource "azurerm_app_service_virtual_network_swift_connection" "webapp_vnet" {
  app_service_id = azurerm_linux_web_app.web.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

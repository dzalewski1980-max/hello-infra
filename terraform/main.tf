locals {
  name = "${var.app}-${var.env}"
  tags = {
    app = var.app
    env = var.env
    iac = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "apps" {
  name                 = "apps"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/23"]
}

resource "azurerm_subnet" "gw" {
  name                 = "gateway"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

module "app" {
  source    = "./modules/container_app"
  name      = local.name
  location  = azurerm_resource_group.rg.location
  rg        = azurerm_resource_group.rg.name
  subnet_id = azurerm_subnet.apps.id
  img       = var.img
  cpu       = var.cpu
  mem       = var.mem
  min_inst  = var.min_inst
  max_inst  = var.max_inst
  tags      = local.tags
}

module "gw" {
  source    = "./modules/app_gateway"
  name      = local.name
  location  = azurerm_resource_group.rg.location
  rg        = azurerm_resource_group.rg.name
  subnet_id = azurerm_subnet.gw.id
  backend   = module.app.fqdn
  tags      = local.tags
}

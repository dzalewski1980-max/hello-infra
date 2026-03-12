resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "waf" {
  name                = "${var.name}-waf"
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "gw" {
  name                = "${var.name}-gw"
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 3
  }

  gateway_ip_configuration {
    name      = "gw-ip"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "fe-ip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  frontend_port {
    name = "port80"
    port = 80
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "fe-ip"
    frontend_port_name             = "port80"
    protocol                       = "Http"
  }

  backend_address_pool {
    name  = "backend-pool"
    fqdns = [var.backend]
  }

  backend_http_settings {
    name                                = "be-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "health"
  }

  probe {
    name                                      = "health"
    protocol                                  = "Http"
    path                                      = "/health"
    interval                                  = 30
    timeout                                   = 10
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }

  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    priority                   = 100
    http_listener_name         = "listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "be-settings"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf.id
}

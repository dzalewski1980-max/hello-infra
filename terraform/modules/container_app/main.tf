resource "azurerm_user_assigned_identity" "id" {
  name                = "${var.name}-id"
  location            = var.location
  resource_group_name = var.rg
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "logs" {
  name                = "${var.name}-logs"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_container_app_environment" "env" {
  name                           = "${var.name}-env"
  location                       = var.location
  resource_group_name            = var.rg
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = true
  tags                           = var.tags
}

resource "azurerm_container_app" "app" {
  name                         = "${var.name}-app"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = var.rg
  revision_mode                = "Single"
  tags                         = var.tags

  template {
    container {
      name   = "app"
      image  = var.img
      cpu    = var.cpu
      memory = var.mem

      liveness_probe {
        path                    = "/"
        port                    = 80
        transport               = "HTTP"
        initial_delay           = 5
        interval_seconds        = 10
        failure_count_threshold = 3
      }

      readiness_probe {
        path             = "/"
        port             = 80
        transport        = "HTTP"
        interval_seconds = 5
      }
    }

    min_replicas = var.min_inst
    max_replicas = var.max_inst

    http_scale_rule {
      name                = "scale-on-http"
      concurrent_requests = "100"
    }
  }

  ingress {
    external_enabled = false
    target_port      = 80
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

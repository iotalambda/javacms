resource "azurerm_container_app" "ca_app" {
  name                         = module.global_vars.ca_app_name
  container_app_environment_id = data.azurerm_container_app_environment.cae.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.uai_ca.id]
  }

  registry {
    server   = data.azurerm_container_registry.acr.login_server
    identity = data.azurerm_user_assigned_identity.uai_ca.id
  }

  template {
    min_replicas = 0
    max_replicas = 1
    container {
      name   = module.global_vars.ca_app_name
      memory = "2Gi"
      cpu    = 1
      image  = "${data.azurerm_container_registry.acr.login_server}/${module.global_vars.ca_app_name}:${var.tag}"
      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "production"
      }
      env {
        name        = "spring.datasource.password"
        secret_name = module.global_vars.oraclesecret_name
      }
    }
  }

  secret {
    identity            = data.azurerm_user_assigned_identity.uai_ca.id
    name                = module.global_vars.oraclesecret_name
    key_vault_secret_id = "${data.azurerm_key_vault.app_kv.vault_uri}secrets/${module.global_vars.oraclesecret_name}"
  }

  ingress {
    target_port                = 8080
    external_enabled           = false
    allow_insecure_connections = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

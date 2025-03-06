resource "azurerm_container_app" "ca_oracle" {
  name                         = "oracle"
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
      name   = "oracle"
      memory = "2Gi"
      cpu    = 1
      image  = "${data.azurerm_container_registry.acr.login_server}/oracle:${var.tag}"
      env {
        name        = "ORACLE_PASSWORD"
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
    exposed_port     = 1521
    target_port      = 1521
    external_enabled = false
    transport        = "tcp"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

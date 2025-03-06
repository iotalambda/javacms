resource "azurerm_container_app" "ca_jcmsui" {
  name                         = "jcmsui"
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
      name   = "jcmsui"
      memory = "2Gi"
      cpu    = 1
      image  = "${data.azurerm_container_registry.acr.login_server}/jcmsui:${var.tag}"

      env {
        name  = "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"
        value = data.azurerm_client_config.current.tenant_id
      }
      env {
        name  = "JCMS_API_BASE_URL"
        value = "http://${module.global_vars.ca_app_name}"
      }
    }
  }

  secret {
    name                = "jcms-entra-clientsecret"
    key_vault_secret_id = data.azurerm_key_vault_secret.entra_clientsecret.id
    identity            = data.azurerm_user_assigned_identity.uai_ca.id
  }

  ingress {
    target_port                = 3000
    external_enabled           = true
    allow_insecure_connections = false
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azapi_resource" "auth_ca_jcmsui" {
  type      = "Microsoft.App/containerApps/authConfigs@2024-10-02-preview"
  name      = "current"
  parent_id = azurerm_container_app.ca_jcmsui.id
  body = {
    properties = {
      globalValidation = {
        redirectToProvider          = "azureActiveDirectory"
        unauthenticatedClientAction = "RedirectToLoginPage"
      }
      identityProviders = {
        azureActiveDirectory = {
          enabled = true
          registration = {
            clientId                = data.azurerm_key_vault_secret.entra_clientid.value
            clientSecretSettingName = "jcms-entra-clientsecret"
            openIdIssuer            = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
          }
          validation = {
            defaultAuthorizationPolicy = {
              allowedApplications = [
                data.azurerm_key_vault_secret.entra_clientid.value
              ]
            }
          }
        }
      }
      login = {
        tokenStore = {
          enabled = true
        }
      }
      platform = {
        enabled = true
      }
    }
  }
}

resource "null_resource" "app_redirect_uris" {
  lifecycle {
    replace_triggered_by = [azurerm_container_app.ca_jcmsui]
  }
  triggers = {
    command = <<-EOT
      $redirectUris = @{ "https://${azurerm_container_app.ca_jcmsui.ingress[0].fqdn}/.auth/login/aad/callback" = $true }

      $appRegDetails = (az ad app show --id "${data.azurerm_key_vault_secret.entra_clientid.value}" | ConvertFrom-Json)

      foreach ($uri in $appRegDetails.web.redirectUris) {
        $redirectUris[$uri] = $true
      }

      az ad app update `
        --id "${data.azurerm_key_vault_secret.entra_clientid.value}" `
        --web-redirect-uris $redirectUris.Keys `
        --output "none"
    EOT
  }

  provisioner "local-exec" {
    command     = self.triggers.command
    interpreter = ["pwsh", "-Command"]
  }
}

resource "azurerm_container_app_environment" "cae" {
  name                               = module.global_vars.cae_name
  location                           = data.azurerm_resource_group.rg.location
  resource_group_name                = data.azurerm_resource_group.rg.name
  infrastructure_subnet_id           = azurerm_subnet.subnet_cae.id
  internal_load_balancer_enabled     = false
  infrastructure_resource_group_name = "jcms-dev-app-cae-infra"
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.la.id
  workload_profile {
    workload_profile_type = "Consumption"
    name                  = "Consumption"
  }
}

resource "null_resource" "azcli_cae" {
  depends_on = [azurerm_container_app_environment.cae]
  lifecycle {
    replace_triggered_by = [azurerm_container_app_environment.cae]
  }

  triggers = {
    command = <<-EOT
      az containerapp env update `
        --name "${azurerm_container_app_environment.cae.name}" `
        --resource-group "${data.azurerm_resource_group.rg.name}" `
        --enable-peer-to-peer-encryption
    EOT
  }

  provisioner "local-exec" {
    command     = self.triggers.command
    interpreter = ["pwsh", "-Command"]
  }
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = "jcms-dev-app-la"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

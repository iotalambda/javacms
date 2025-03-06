resource "azurerm_container_registry" "acr" {
  name                = module.global_vars.acr_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "acr_roleassignment_acrpush" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "ACRPush"
  principal_id         = data.azurerm_key_vault_secret.devsobjectid.value
}

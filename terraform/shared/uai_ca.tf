resource "azurerm_user_assigned_identity" "uai_ca" {
  name                = module.global_vars.uai_ca_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "uai_ca_acr_acrpull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.uai_ca.principal_id
}

resource "azurerm_role_assignment" "uai_ca_kv_keyvaultsecretsuser" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.uai_ca.principal_id
}

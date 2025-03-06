resource "azurerm_role_assignment" "mgmt_kv_roleassignment_keyvaultsecretsuser" {
  scope                = data.azurerm_key_vault.mgmt_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.uai_ca.principal_id
}

resource "random_password" "oraclesecret" {
  length           = 16
  special          = true
  override_special = "_"
}

resource "azurerm_key_vault_secret" "oraclesecret" {
  depends_on   = [azurerm_role_assignment.principal_kv_keyvaultadministrator]
  key_vault_id = azurerm_key_vault.kv.id
  name         = module.global_vars.oraclesecret_name
  value        = random_password.oraclesecret.result
}

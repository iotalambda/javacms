data "azurerm_resource_group" "rg" {
  name = module.global_vars.rg_name
}

data "azurerm_key_vault" "mgmt_kv" {
  name                = module.global_vars.mgmt_kv_name
  resource_group_name = module.global_vars.mgmt_rg_name
}

data "azurerm_key_vault_secret" "devsobjectid" {
  key_vault_id = data.azurerm_key_vault.mgmt_kv.id
  name         = "jcms-devsobjectid"
}

data "azurerm_client_config" "current" {}

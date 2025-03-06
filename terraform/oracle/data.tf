data "azurerm_resource_group" "rg" {
  name = module.global_vars.rg_name
}

data "azurerm_container_app_environment" "cae" {
  name                = module.global_vars.cae_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "uai_ca" {
  name                = module.global_vars.uai_ca_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_container_registry" "acr" {
  name                = module.global_vars.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault" "app_kv" {
  name                = module.global_vars.app_kv_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_key_vault_secret" "oraclesecret" {
  key_vault_id = data.azurerm_key_vault.app_kv.id
  name         = module.global_vars.oraclesecret_name
}

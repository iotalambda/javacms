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

data "azurerm_key_vault" "mgmt_kv" {
  name                = module.global_vars.mgmt_kv_name
  resource_group_name = module.global_vars.mgmt_rg_name
}

data "azurerm_key_vault_secret" "entra_clientid" {
  key_vault_id = data.azurerm_key_vault.mgmt_kv.id
  name         = "jcms-entra-clientid"
}

data "azurerm_key_vault_secret" "entra_clientsecret" {
  key_vault_id = data.azurerm_key_vault.mgmt_kv.id
  name         = "jcms-entra-clientsecret"
}

data "azurerm_client_config" "current" {}

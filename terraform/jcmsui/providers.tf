terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "2.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {}
}

terraform {
  required_version = "~> 1.10.4"
  backend "azurerm" {
    key = "jcms.tfstate"
  }
}

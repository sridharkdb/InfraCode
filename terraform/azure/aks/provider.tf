terraform {
  required_version = ">=1.0"

  backend "azurerm" {
    resource_group_name  = "sndev"
    storage_account_name = "tfmbkp"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "azurerm" {
  features {}
}

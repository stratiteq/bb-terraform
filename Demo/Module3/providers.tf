############
# Providers
############
provider "azurerm" {}

/*
# Use Azure storage account for state file
terraform {
  backend "azurerm" {
    storage_account_name = "terraformbuildstates"
    container_name       = "dev"
    key                  = "default-terraform.tfstate"
    access_key           = "<my access key for the storage account>"
    resource_group_name  = "terraform"
  }
}
// terraform init --backend-config="key=bobberino.tfstate"
*/
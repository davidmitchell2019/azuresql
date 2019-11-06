provider "azurerm" {
  version = "=1.36.0"
}
terraform {
  backend "azurerm" {
    storage_account_name  = "AksTerraform-RG"
    container_name        = "tfstate-postgres"
    key                   = "terraform.tfstate"
    resource_group_name  = "postgresql-database-deutsche-bank"
  }
}

# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

provider "azurerm" {
  features {}

  # TODO: Authenticate with service principal
  subscription_id   = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  tenant_id         = "0f8c9257-a4ad-4069-916f-9bfb26c42d38"
  client_id         = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
  client_secret     = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    secret = {
      source = "numtide/secret"
    }
  }
}

################################################################################

terraform {
  # Backend for storing terraform state (see ../state-storage)
  backend "azurerm" {
    resource_group_name  = "ghaf-infra-state"
    storage_account_name = "ghafinfrauaestatestorage"
    container_name       = "ghaf-infra-tfstate-container"
    key                  = "ghaf-infra-persistent.tfstate"
  }
}

################################################################################

# Variables
variable "location" {
  type        = string
  default     = "northeurope"
  description = "Azure region into which the resources will be deployed"
}

locals {
  # Raise an error if workspace is 'default',
  # this is a workaround to missing asserts in terraform:
  assert_workspace_not_default = regex(
    (terraform.workspace == "default") ?
  "((Force invalid regex pattern)\n\nERROR: workspace 'default' is not allowed" : "", "")

  # Sanitize workspace name:
  # Workspace name defines the persistent instance
  ws = substr(replace(lower(terraform.workspace), "/[^a-z0-9]/", ""), 0, 16)
}

# Resource group
resource "azurerm_resource_group" "persistent" {
  name     = "ghaf-infra-persistent-${local.ws}"
  location = var.location
}

# Current signed-in user
#data "azurerm_client_config" "current" {}

################################################################################

# Resources

# secret_resouce must be created on import, e.g.:
#
#   nix-store --generate-binary-cache-key foo secret-key public-key
#   terraform import secret_resource.binary_cache_signing_key_dev "$(< ./secret-key)"
#   terraform apply
#
# Ghaf-infra automates the creation in 'init-ghaf-infra.sh'
resource "secret_resource" "binary_cache_signing_key_dev" {
  lifecycle {
    prevent_destroy = true
  }
}
resource "secret_resource" "binary_cache_signing_key_prod" {
  lifecycle {
    prevent_destroy = true
  }
}

module "builder_ssh_key_prod" {
  source = "./builder-ssh-key"
  # Must be globally unique
  builder_ssh_keyvault_name = "ssh-builder-prod-${local.ws}"
  resource_group_name       = azurerm_resource_group.persistent.name
  location                  = azurerm_resource_group.persistent.location
  tenant_id                 = "0f8c9257-a4ad-4069-916f-9bfb26c42d38"
  #tenant_id                 = data.azurerm_client_config.current.tenant_id
}

module "builder_ssh_key_dev" {
  source = "./builder-ssh-key"
  # Must be globally unique
  builder_ssh_keyvault_name = "ssh-builder-dev-${local.ws}"
  resource_group_name       = azurerm_resource_group.persistent.name
  location                  = azurerm_resource_group.persistent.location
  tenant_id                 = "0f8c9257-a4ad-4069-916f-9bfb26c42d38"
  #tenant_id                 = data.azurerm_client_config.current.tenant_id
}

module "binary_cache_sigkey_prod" {
  source = "./binary-cache-sigkey"
  # Must be globally unique
  bincache_keyvault_name = "bche-sigkey-prod-${local.ws}"
  secret_resource        = secret_resource.binary_cache_signing_key_prod
  resource_group_name    = azurerm_resource_group.persistent.name
  location               = azurerm_resource_group.persistent.location
  tenant_id              = "0f8c9257-a4ad-4069-916f-9bfb26c42d38"
  #tenant_id              = data.azurerm_client_config.current.tenant_id
}

module "binary_cache_sigkey_dev" {
  source = "./binary-cache-sigkey"
  # Must be globally unique
  bincache_keyvault_name = "bche-sigkey-dev-${local.ws}"
  secret_resource        = secret_resource.binary_cache_signing_key_dev
  resource_group_name    = azurerm_resource_group.persistent.name
  location               = azurerm_resource_group.persistent.location
  tenant_id              = "0f8c9257-a4ad-4069-916f-9bfb26c42d38"
  #tenant_id              = data.azurerm_client_config.current.tenant_id
}

module "binary_cache_storage_prod" {
  source = "./binary-cache-storage"
  # Must be globally unique
  bincache_storage_account_name = "ghafbincacheprod2${local.ws}"
  resource_group_name           = azurerm_resource_group.persistent.name
  location                      = azurerm_resource_group.persistent.location
}

module "binary_cache_storage_dev" {
  source = "./binary-cache-storage"
  # Must be globally unique
  bincache_storage_account_name = "ghafbincachedev2${local.ws}"
  resource_group_name           = azurerm_resource_group.persistent.name
  location                      = azurerm_resource_group.persistent.location
}

################################################################################


###############################################################################
# versions.tf — Providers and Terraform version (single source of truth)
###############################################################################

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

# Single provider configuration (no duplicates elsewhere)
provider "ibm" {
  region = var.region
}

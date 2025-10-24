###############################################################################
# Main — Vibe IDE Deployable Architecture
###############################################################################

terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    null = {
      source  = "hashicorp/null"
    }
  }
}

provider "ibm" {}

###############################################################################
# Random suffix for unique bucket naming
###############################################################################

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

###############################################################################
# COS Instance and Bucket
###############################################################################

resource "ibm_resource_instance" "vibe_cos_instance" {
  name              = "vibe-instance-${random_string.suffix.result}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name = "vibe-bucket-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.vibe_cos_instance.id
  region = var.region
  storage_class = "standard"
}

###############################################################################
# COS Static Website Configuration (v1.84+ syntax)
###############################################################################

resource "ibm_cos_bucket_website_configuration" "vibe_site" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region

  website_configuration {
    index_document = "index.html"
    error_document = "index.html"
  }
}

###############################################################################
# Code Engine Project (for optional backend)
###############################################################################

resource "ibm_code_engine_project" "vibe_ce_project" {
  name     = "vibe-ce-${random_string.suffix.result}"
  region   = var.region
}

###############################################################################
# Render Environment (write env.js)
###############################################################################

resource "null_resource" "render_env" {
  provisioner "local-exec" {
    command = <<EOT
      echo "window.CODE_ENGINE_URL='${ibm_code_engine_project.vibe_ce_project.name}'" > env.js
    EOT
  }
}

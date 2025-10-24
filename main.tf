###############################################################################
# Vibe IDE — Deployable Architecture (IBM Cloud)
# Fixed for Terraform init compatibility (HCL-compliant syntax)
###############################################################################

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
  required_version = ">= 1.3.0"
}

###############################################################################
# Providers & Locals
###############################################################################

provider "ibm" {
  region = var.region
}

locals {
  vibe_suffix = random_id.suffix.hex
}

resource "random_id" "suffix" {
  byte_length = 2
}

###############################################################################
# Object Storage — Vibe Bucket
###############################################################################

resource "ibm_resource_instance" "cos_instance" {
  name              = "vibe-instance-${local.vibe_suffix}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_resource_group" "group" {
  name = "Default"
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "vibe-bucket-${local.vibe_suffix}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true

  website {
    enable             = true
    main_document      = "index.html"
    error_document     = "index.html"
  }
}

###############################################################################
# Code Engine Project (optional future extension)
###############################################################################

resource "ibm_code_engine_project" "vibe_ce_project" {
  name = "vibe-code-engine-${local.vibe_suffix}"
}

###############################################################################
# Local Render Environment — Fix applied here
###############################################################################

resource "null_resource" "render_env" {
  provisioner "local-exec" {
    environment = {
      CODE_ENGINE_URL = "${ibm_code_engine_project.vibe_ce_project.status_url}"
    }

    command = <<EOT
      echo "Rendering environment with CODE_ENGINE_URL=${ibm_code_engine_project.vibe_ce_project.status_url}"
    EOT
  }
}

###############################################################################
# Outputs
###############################################################################

output "primaryoutputlink" {
  value       = "https://${ibm_cos_bucket.vibe_bucket.website_endpoint}"
  description = "Vibe IDE URL"
}

output "code_engine_url" {
  value       = ibm_code_engine_project.vibe_ce_project.status_url
  description = "Code Engine Backend URL"
}

output "vibe_bucket_name" {
  value       = ibm_cos_bucket.vibe_bucket.bucket_name
  description = "COS Bucket Name"
}

output "vibe_bucket_website_endpoint" {
  value       = ibm_cos_bucket.vibe_bucket.website_endpoint
  description = "COS Website Endpoint"
}

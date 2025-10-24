###############################################################################
# Vibe IDE — Deployable Architecture (IBM Cloud)
# Modular structure (no duplicate providers/outputs)
###############################################################################

locals {
  vibe_suffix = random_id.suffix.hex
}

resource "random_id" "suffix" {
  byte_length = 2
}

###############################################################################
# Object Storage — Vibe Bucket
###############################################################################

data "ibm_resource_group" "group" {
  name = "Default"
}

resource "ibm_resource_instance" "cos_instance" {
  name              = "vibe-instance-${local.vibe_suffix}"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.group.id
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "vibe-bucket-${local.vibe_suffix}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.region
  storage_class        = "standard"
  force_delete         = true
}

# Enable static website hosting
resource "ibm_cos_bucket_website_configuration" "vibe_site" {
  bucket_crn     = ibm_cos_bucket.vibe_bucket.crn
  main_document  = "index.html"
  error_document = "index.html"
}

###############################################################################
# Code Engine Project (optional backend for APIs)
###############################################################################

resource "ibm_code_engine_project" "vibe_ce_project" {
  name = "vibe-code-engine-${local.vibe_suffix}"
}

###############################################################################
# Local Render Environment
###############################################################################

resource "null_resource" "render_env" {
  provisioner "local-exec" {
    environment = {
      CODE_ENGINE_PROJECT = ibm_code_engine_project.vibe_ce_project.name
    }
    command = <<EOT
      echo "Rendering environment with CODE_ENGINE_PROJECT=${ibm_code_engine_project.vibe_ce_project.name}"
    EOT
  }
}

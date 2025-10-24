provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

# COS instance and bucket
resource "ibm_resource_instance" "cos" {
  name              = var.cos_instance_name
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

locals {
  resolved_bucket = var.bucket_name != "" ? var.bucket_name : "vibe-site-${random_string.suffix.result}"
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = local.resolved_bucket
  resource_instance_id = ibm_resource_instance.cos.id
  storage_class        = "smart"
  region_location      = var.region
  force_delete         = true
}

# Upload starter files (using current provider args)
resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = ibm_cos_bucket.vibe_bucket.region_location
  key             = "index.html"
  file            = "${path.module}/index.html"
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = ibm_cos_bucket.vibe_bucket.region_location
  key             = "assets/env.js"
  file            = "${path.module}/assets/env.js"
}

resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = ibm_cos_bucket.vibe_bucket.region_location
  key             = "assets/api.js"
  file            = "${path.module}/assets/api.js"
}

# Cloud Functions namespace + action
resource "ibm_function_namespace" "vibe_ns" {
  name              = var.function_namespace
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "ibm_function_action" "vibe_push" {
  name      = var.function_action_name
  namespace = ibm_function_namespace.vibe_ns.name

  exec {
    kind = "nodejs:20"
    code = file("${path.module}/function/manifest_vibe.js")
    main = "main"
  }
}

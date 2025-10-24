provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  name = var.resource_group_name
}

# ----- COS: Instance and bucket (no website config to avoid provider brittleness) -----
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

# Optional: push starter files into the bucket
resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn   = ibm_cos_bucket.vibe_bucket.crn
  bucket       = ibm_cos_bucket.vibe_bucket.bucket_name
  key          = "index.html"
  data         = file("${path.module}/index.html")
  # content_type is computed by provider; do not set to avoid errors
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn   = ibm_cos_bucket.vibe_bucket.crn
  bucket       = ibm_cos_bucket.vibe_bucket.bucket_name
  key          = "assets/env.js"
  data         = file("${path.module}/assets/env.js")
}

resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn   = ibm_cos_bucket.vibe_bucket.crn
  bucket       = ibm_cos_bucket.vibe_bucket.bucket_name
  key          = "assets/api.js"
  data         = file("${path.module}/assets/api.js")
}

# ----- Cloud Functions: Namespace + Action -----
resource "ibm_function_namespace" "vibe_ns" {
  name               = var.function_namespace
  resource_group_id  = data.ibm_resource_group.rg.id
}

# NOTE: Keep attributes minimal for maximum compatibility with provider versions.
# We avoid parameters/annotations here; you can enable web later via CLI if desired.
resource "ibm_function_action" "vibe_push" {
  name       = var.function_action_name
  namespace  = ibm_function_namespace.vibe_ns.name

  exec {
    kind = "nodejs:20"
    code = file("${path.module}/function/manifest_vibe.js")
    main = "main"
  }
}

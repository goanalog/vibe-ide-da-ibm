
###############################################################################
# main.tf — Resources only
###############################################################################

# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 3
}

###############################################################################
# Cloud Object Storage (COS) instance and bucket
###############################################################################

resource "ibm_resource_instance" "vibe_cos" {
  name     = "vibe-cos-${random_id.suffix.hex}"
  service  = "cloud-object-storage"
  plan     = "lite"
  location = "global"
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name           = "vibe-bucket-${random_id.suffix.hex}"
  resource_instance_id  = ibm_resource_instance.vibe_cos.id
  region_location       = var.region
  storage_class         = "standard"
}

# Static website configuration (v1.84+ syntax)
resource "ibm_cos_bucket_website_configuration" "vibe_site" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region

  website_configuration {
    index_document = "index.html"
    error_document = "index.html"
  }
}

###############################################################################
# IBM Cloud Function — Vibe Push (serverless live update)
###############################################################################

resource "ibm_function_namespace" "vibe_ns" {
  name = "vibe-namespace-${random_id.suffix.hex}"
}

resource "ibm_function_action" "vibe_push" {
  name      = "vibe-push"
  namespace = ibm_function_namespace.vibe_ns.name
  runtime   = "python:3.11"

  exec {
    kind = "python:3.11"
    code = file("${path.module}/vibe_push.py")
    main = "main"
  }
}

resource "ibm_function_web_action" "vibe_push_web" {
  action_name   = ibm_function_action.vibe_push.name
  namespace     = ibm_function_namespace.vibe_ns.name
  base_path     = "default"
  name          = "vibe-push"
  response_type = "json"
  publish       = true
}

###############################################################################
# Auto-upload front-end assets to COS (change-only via ETag checks)
###############################################################################

resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "index.html"
  content         = file("${path.module}/index.html")
  content_type    = "text/html"
  etag_check      = true
  etag            = filemd5("${path.module}/index.html")
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/env.js"
  content         = file("${path.module}/js/env.js")
  content_type    = "application/javascript"
  etag_check      = true
  etag            = filemd5("${path.module}/js/env.js")
}

resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/api.js"
  content         = file("${path.module}/js/api.js")
  content_type    = "application/javascript"
  etag_check      = true
  etag            = filemd5("${path.module}/js/api.js")
}


###############################################################################
# main.tf — Resources only (IBM provider >= 1.84.0 compatible)
###############################################################################

resource "random_id" "suffix" {
  byte_length = 3
}

# Default resource group lookup for Functions
data "ibm_resource_group" "default" {
  name = "Default"
}

###############################################################################
# Cloud Object Storage (COS)
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

resource "ibm_cos_bucket_website_configuration" "vibe_site" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region

  website_configuration {
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "index.html"
    }
  }
}

###############################################################################
# IBM Cloud Functions — Namespace & Action (web-enabled)
###############################################################################
resource "ibm_function_namespace" "vibe_ns" {
  name              = "vibe-namespace-${random_id.suffix.hex}"
  resource_group_id = data.ibm_resource_group.default.id
}

# Notes:
#  - Some provider versions expose 'web = true' flag; others require annotations.
#  - We compute the web URL in outputs to avoid relying on a separate resource.
resource "ibm_function_action" "vibe_push" {
  name      = "vibe-push"
  namespace = ibm_function_namespace.vibe_ns.name
  runtime   = "python:3.11"

  # Default parameters so the frontend doesn't need to send bucket/region
  parameters = {
    bucket = ibm_cos_bucket.vibe_bucket.bucket_name
    region = var.region
  }

  exec {
    kind = "python:3.11"
    code = file("${path.module}/vibe_push.py")
    main = "main"
  }

  # Web-enable via annotations to be provider-compatible
  annotations = {
    "web-export" = "true"
    "final"      = "true"
    "raw-http"   = "false"
  }

  publish = true
}

###############################################################################
# Upload front-end assets to COS
###############################################################################

# Render env.js from template with function URL, bucket, region
resource "local_file" "rendered_env" {
  filename = "${path.module}/js/env.rendered.js"
  content  = templatefile("${path.module}/env.tmpl.js", {
    function_url = "https://${var.region}.functions.appdomain.cloud/api/v1/web/${ibm_function_namespace.vibe_ns.name}/default/${ibm_function_action.vibe_push.name}"
    bucket       = ibm_cos_bucket.vibe_bucket.bucket_name
    region       = var.region
  })
}

# index.html
resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "index.html"
  content         = file("${path.module}/index.html")
  content_type    = "text/html"
}

# env.js (rendered)
resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/env.js"
  content         = file(local_file.rendered_env.filename)
  content_type    = "application/javascript"
  depends_on      = [local_file.rendered_env]
}

# api.js
resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/api.js"
  content         = file("${path.module}/js/api.js")
  content_type    = "application/javascript"
}

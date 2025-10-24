
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

provider "ibm" {}

resource "random_id" "suffix" {
  byte_length = 3
}

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
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "ibm_function_namespace" "vibe_ns" {
  name = "vibe-namespace-${random_id.suffix.hex}"
}

resource "ibm_function_action" "vibe_push" {
  name        = "vibe-push"
  namespace   = ibm_function_namespace.vibe_ns.name
  runtime     = "python:3.11"
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

output "primaryoutputlink" {
  description = "Website URL"
  value       = "https://${ibm_cos_bucket.vibe_bucket.bucket_name}.s3-website.${var.region}.cloud-object-storage.appdomain.cloud"
}

output "vibe_push_function_url" {
  description = "Public URL for the Vibe Push Function"
  value       = ibm_function_web_action.vibe_push_web.web_action_url
}

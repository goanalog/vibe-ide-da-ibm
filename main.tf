terraform {
  required_version = ">= 1.5.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.84.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "rg" {
  name = var.resource_group
}

resource "ibm_resource_instance" "cos" {
  name              = "vibe-cos"
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
  resource_group_id = data.ibm_resource_group.rg.id
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  number  = true
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "vibe-site-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "smart"
  endpoint_type        = "public"
  force_delete         = true
}

resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "index.html"
  content         = file("${path.module}/index.html")
  endpoint_type   = "public"
  force_delete    = true
  depends_on      = [ibm_cos_bucket.vibe_bucket]
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/env.js"
  content         = file("${path.module}/assets/env.js")
  endpoint_type   = "public"
  force_delete    = true
  depends_on      = [ibm_cos_bucket.vibe_bucket]
}

resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/api.js"
  content         = file("${path.module}/assets/api.js")
  endpoint_type   = "public"
  force_delete    = true
  depends_on      = [ibm_cos_bucket.vibe_bucket]
}

resource "ibm_cos_bucket_object" "ui_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/ui.js"
  content         = file("${path.module}/assets/ui.js")
  endpoint_type   = "public"
  force_delete    = true
  depends_on      = [ibm_cos_bucket.vibe_bucket]
}

output "bucket_name" {
  value = ibm_cos_bucket.vibe_bucket.bucket_name
}

output "public_base_url" {
  value = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}"
}

output "vibe_ide_url" {
  value = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}/index.html"
}
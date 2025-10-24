terraform {
  required_version = ">= 1.3.0"
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
  name = var.resource_group_name
}

resource "ibm_resource_instance" "cos" {
  name              = "${var.prefix}-cos"
  resource_group_id = data.ibm_resource_group.rg.id
  service           = "cloud-object-storage"
  plan              = "lite"
  location          = "global"
}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  number  = true
  special = false
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "${var.prefix}-site-${random_string.suffix.result}"
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
  endpoint_type   = "public"
  content         = file("${path.module}/www/index.html")
  force_delete    = true
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/env.js"
  endpoint_type   = "public"
  content         = templatefile("${path.module}/www/assets/env.tmpl.js", { project_url = var.project_url })
  force_delete    = true
}

resource "ibm_cos_bucket_object" "app_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/app.js"
  endpoint_type   = "public"
  content         = file("${path.module}/www/assets/app.js")
  force_delete    = true
}

output "bucket_name" {
  value = ibm_cos_bucket.vibe_bucket.bucket_name
}

locals {
  public_base_url = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}"
}

output "public_base_url" {
  value = local.public_base_url
}

output "vibe_ide_url" {
  value = "${local.public_base_url}/index.html"
}
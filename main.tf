resource "ibm_resource_instance" "cos_instance" {
  name     = "vibe-instance"
  service  = "cloud-object-storage"
  plan     = "lite"
  location = "global"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "ibm_cos_bucket" "vibe_bucket" {
  bucket_name          = "${var.bucket_prefix}-${random_string.suffix.result}"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  storage_class        = "standard"
  force_delete         = true
  region_location      = var.region
}

resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = var.website_index
  content         = file("${path.module}/sample-app/index.html")
}

resource "ibm_cos_bucket_object" "error_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = var.website_error
  content         = file("${path.module}/sample-app/404.html")
}

resource "ibm_cos_bucket_website_configuration" "vibe_bucket_website" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region

  website_configuration {
    index_document {
      suffix = var.website_index
    }

    error_document {
      key = var.website_error
    }
  }

  # Fixes race condition
  depends_on = [
    ibm_cos_bucket_object.index_html,
    ibm_cos_bucket_object.error_html
  ]
}

# Fixes 403 AccessDenied error using the correct resource for public access
resource "ibm_iam_access_group_policy" "vibe_bucket_public_read_policy" {
  access_group_id = "AccessGroupId-PublicAccess" # ID for the built-in Public Access group
  roles           = ["ContentReader"]

  resources {
    service               = "cloud-object-storage"
    resource_instance_id  = ibm_resource_instance.cos_instance.id
    resource_type         = "bucket"
    resource              = ibm_cos_bucket.vibe_bucket.bucket_name
  }
}
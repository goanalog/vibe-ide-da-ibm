locals {
  # Suffix for global-unique names;
  # stable per workspace run.
  suffix = lower(replace(random_string.sfx.result, "/[^a-z0-9]/", ""))
  region = var.region
  # Base names
  cos_name    = "vibe-ide-cos-${local.suffix}"
  bucket_name = "vibe-ide-bucket-${local.suffix}"
}

provider "ibm" {
  region = local.region
}

resource "random_string" "sfx" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

# --------------------------
# Cloud Object Storage
# --------------------------

# Look up the existing instance if an ID was provided
data "ibm_resource_instance" "existing_cos" {
  count = var.existing_cos_instance_id != "" ? 1 : 0
  id    = var.existing_cos_instance_id
}

# Create a new 'lite' instance ONLY if no existing ID was provided
resource "ibm_resource_instance" "cos" {
  count    = var.existing_cos_instance_id == "" ? 1 : 0 # <-- Conditional creation
  name     = local.cos_name
  service  = "cloud-object-storage"
  plan     = var.cos_plan
  location = "global"
  tags     = ["vibe", "vibe-ide", "static-site"]
}

# Use a local variable to get the correct ID and Name from either the new or existing resource
locals {
  cos_instance_id   = var.existing_cos_instance_id != "" ? data.ibm_resource_instance.existing_cos[0].id : ibm_resource_instance.cos[0].id
  cos_instance_name = var.existing_cos_instance_id != "" ? data.ibm_resource_instance.existing_cos[0].name : ibm_resource_instance.cos[0].name
}


# Regional bucket for website hosting
resource "ibm_cos_bucket" "site" {
  bucket_name          = local.bucket_name
  resource_instance_id = local.cos_instance_id # <-- Use local
  region_location      = var.bucket_region
  storage_class        = var.bucket_storage_class
  force_delete         = true
}

# Website configuration
resource "ibm_cos_bucket_website" "site" {
  bucket_crn  = ibm_cos_bucket.site.crn
  index_doc   = "index.html"
  error_doc   = "index.html"
}

# --------------------------
# Public Access Policy (Automated)
# --------------------------

# Look up the well-known "Public Access" group
data "ibm_iam_access_group" "public_access" {
  name = "Public Access"
}

# Apply the "Object Reader" role to the Public Access group
resource "ibm_iam_access_group_policy" "bucket_public_read" {
  access_group_id = data.ibm_iam_access_group.public_access.id
  roles           = ["Object Reader"]
  description     = "Public read-only access for the Vibe IDE static site bucket."

  resources {
    service              = "cloud-object-storage"
    resource_instance_id = local.cos_instance_id # <-- Use local
    resource_type        = "bucket"
    resource             = ibm_cos_bucket.site.bucket_name
  }
}


# Upload the initial index.html
# If var.initial_html is non-empty, use it; otherwise use the bundled sample file.
locals {
  # Use templatefile to inject dynamic data into the sample HTML
  template_content = templatefile("${path.module}/static-site/index.html.tftpl", {
    # This creates the dynamic message for the "wow" factor
    status_message = "DEPLOYED TO ${upper(var.bucket_region)} | BUCKET: ${ibm_cos_bucket.site.bucket_name}"
  })

  initial_index_content = trim(var.initial_html) != "" ? var.initial_html : local.template_content
}

resource "ibm_cos_bucket_object" "index" {
  resource_instance_id = local.cos_instance_id # <-- Use local
  bucket_crn           = ibm_cos_bucket.site.crn
  key                  = "index.html"
  content              = local.initial_index_content
  content_type         = "text/html"
  force                = true
}
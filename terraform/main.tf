data "ibm_resource_group" "rg" {
  name = "Default"
}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "ibm_resource_instance" "cos" {
  name     = "${var.prefix}-cos"
  service  = "cloud-object-storage"
  plan     = "lite"
  location = "global"
  resource_group_id = data.ibm_resource_group.rg.id
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
  content         = file("${path.module}/../www/index.html")
  force_delete    = true
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/env.js"
  endpoint_type   = "public"
  content         = templatefile("${path.module}/../www/assets/env.tmpl.js", {
    APPID_CLIENT_ID = ibm_appid_application.vibe_frontend.client_id
    APPID_TENANT_ID = ibm_resource_instance.appid.guid
    APP_REGION      = var.region
    PUSH_API_URL    = "https://${ibm_codeengine_app.broker.latest_revision_name}.${ibm_codeengine_app.broker.endpoint}/publish"
  })
  force_delete    = true
}

resource "ibm_cos_bucket_object" "app_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "assets/app.js"
  endpoint_type   = "public"
  content         = file("${path.module}/../www/assets/app.js")
  force_delete    = true
}

resource "ibm_resource_instance" "appid" {
  name     = "${var.prefix}-appid"
  service  = "appid"
  plan     = "lite"
  location = var.region
  resource_group_id = data.ibm_resource_group.rg.id
  tags = ["vibe-ide"]
}

resource "ibm_appid_application" "vibe_frontend" {
  tenant_id = ibm_resource_instance.appid.guid
  name      = "${var.prefix}-frontend"
  type      = "regularwebapp"

  redirect_uris = [
    "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}/index.html"
  ]
}

resource "ibm_iam_service_id" "broker_sid" {
  name        = "${var.prefix}-broker-sid"
  description = "Vibe IDE broker"
}

resource "ibm_iam_service_api_key" "broker_key" {
  name        = "${var.prefix}-broker-key"
  service_id  = ibm_iam_service_id.broker_sid.id
  description = "API key for broker"
  store_value = true
}

resource "ibm_iam_service_policy" "broker_policy" {
  iam_service_id = ibm_iam_service_id.broker_sid.id
  roles          = ["Object Writer"]

  resources {
    service              = "cloud-object-storage"
    resource_instance_id = ibm_resource_instance.cos.guid
    resource_type        = "bucket"
    resource_name        = ibm_cos_bucket.vibe_bucket.bucket_name
  }
}

resource "ibm_codeengine_project" "project" {
  name = "${var.prefix}-project-${random_string.suffix.result}"
}

resource "ibm_codeengine_secret" "cos_secret" {
  project_id = ibm_codeengine_project.project.id
  name       = "${var.prefix}-cos-secret"
  format     = "generic"

  data = {
    COS_API_KEY      = ibm_iam_service_api_key.broker_key.api_key
    COS_ENDPOINT     = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud"
    COS_INSTANCE_CRN = ibm_resource_instance.cos.id
    BUCKET_NAME      = ibm_cos_bucket.vibe_bucket.bucket_name
    APPID_TENANT_ID  = ibm_resource_instance.appid.guid
    APP_REGION       = var.region
  }
}

resource "ibm_codeengine_app" "broker" {
  project_id      = ibm_codeengine_project.project.id
  name            = "${var.prefix}-broker"
  image_reference = var.broker_image
  min_scale       = 0
  max_scale       = 1

  env_from_secret = [ibm_codeengine_secret.cos_secret.name]
}

output "vibe_ide_url" {
  value = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}/index.html"
}

output "broker_publish_url" {
  value = "https://${ibm_codeengine_app.broker.latest_revision_name}.${ibm_codeengine_app.broker.endpoint}/publish"
}

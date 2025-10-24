
###############################################################################
# main.tf — v13: Correct Function Action schema with parameters & annotations blocks
###############################################################################

resource "random_id" "suffix" {
  byte_length = 3
}

data "ibm_resource_group" "default" {
  name = "Default"
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
    index_document {
      suffix = "index.html"
    }
    error_document {
      key = "index.html"
    }
  }
}

resource "ibm_function_namespace" "vibe_ns" {
  name              = "vibe-namespace-${random_id.suffix.hex}"
  resource_group_id = data.ibm_resource_group.default.id
}

resource "ibm_function_action" "vibe_push" {
  name      = "vibe-push"
  namespace = ibm_function_namespace.vibe_ns.name

  exec {
    kind = "python:3.11"
    code = file("${path.module}/vibe_push.py")
    main = "main"
  }

  parameters {
    name  = "bucket"
    value = ibm_cos_bucket.vibe_bucket.bucket_name
  }

  parameters {
    name  = "region"
    value = var.region
  }

  annotations {
    name  = "web-export"
    value = true
  }

  annotations {
    name  = "final"
    value = true
  }

  annotations {
    name  = "raw-http"
    value = false
  }

  publish = true
}

resource "local_file" "rendered_env" {
  filename = "${path.module}/js/env.rendered.js"
  content  = templatefile("${path.module}/env.tmpl.js", {
    function_url = "https://${var.region}.functions.appdomain.cloud/api/v1/web/${ibm_function_namespace.vibe_ns.name}/default/${ibm_function_action.vibe_push.name}"
    bucket       = ibm_cos_bucket.vibe_bucket.bucket_name
    region       = var.region
  })
}

resource "ibm_cos_bucket_object" "index_html" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "index.html"
  content         = file("${path.module}/index.html")
}

resource "ibm_cos_bucket_object" "env_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/env.js"
  content         = file(local_file.rendered_env.filename)
  depends_on      = [local_file.rendered_env]
}

resource "ibm_cos_bucket_object" "api_js" {
  bucket_crn      = ibm_cos_bucket.vibe_bucket.crn
  bucket_location = var.region
  key             = "js/api.js"
  content         = file("${path.module}/js/api.js")
}

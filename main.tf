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

resource "random_id" "bucket" { byte_length = 3 }

locals { bucket_name = "${var.bucket_prefix}-${random_id.bucket.hex}" }

resource "ibm_cos_bucket" "site" {
  bucket_name          = local.bucket_name
  resource_instance_id = ibm_resource_instance.cos.id
  region_location      = var.region
  storage_class        = "standard"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["etag"]
    max_age_seconds = 300
  }

  force_destroy = true
}

resource "ibm_cos_bucket_policy" "public_read" {
  count                 = var.enable_public_read ? 1 : 0
  bucket_name           = ibm_cos_bucket.site.bucket_name
  resource_instance_id  = ibm_resource_instance.cos.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = ["arn:aws:s3:::${ibm_cos_bucket.site.bucket_name}/*"]
    }]
  })
}

resource "ibm_code_engine_project" "proj" {
  name              = "vibe-proj"
  resource_group_id = data.ibm_resource_group.rg.id
  region            = var.region
}

resource "ibm_code_engine_app" "broker" {
  name                = "vibe-broker"
  project_id          = ibm_code_engine_project.proj.id
  image_reference     = var.ce_image
  endpoint_visibility = "public"
  port                = 8080

  scale_min_instances = 0
  scale_max_instances = 1
  scale_cpu_limit     = "0.25"
  scale_memory_limit  = "0.5G"

  env { name = "BUCKET_NAME" value = ibm_cos_bucket.site.bucket_name }
  env { name = "BUCKET_REGION" value = var.region }
  env { name = "COS_INSTANCE_CRN" value = ibm_resource_instance.cos.id }
}

data "template_file" "env_js" {
  template = file("${path.module}/sample-app/assets/env.js.tmpl")
  vars = {
    REGION         = var.region
    PUSH_API_URL   = ibm_code_engine_app.broker.endpoint
    PRIMARY_OUTPUT = ibm_cos_bucket.site.website_endpoint
    PROJECT_ID     = ""
    PROJECT_URL    = ""
    CATALOG_IMPORT_URL = ""
    APPID_CLIENT_ID = ""
    APPID_TENANT_ID = ""
    APP_REGION      = var.region
  }
}

resource "local_file" "env_js_out" {
  content  = data.template_file.env_js.rendered
  filename = "${path.module}/sample-app/assets/env.js"
}

resource "null_resource" "initial_publish" {
  depends_on = [ibm_code_engine_app.broker, ibm_cos_bucket.site, local_file.env_js_out]

  provisioner "local-exec" {
    command = <<'EOT'
set -e
BROKER="${broker}"
INDEX="${sample}"
ENVJS="${envjs}"
echo "Waiting for broker readiness at $BROKER ..."
for i in 1 2 3 4 5 6 7 8; do
  if curl -sSf -m 5 "$BROKER/health" >/dev/null 2>&1; then
    echo "Broker is healthy."
    break
  fi
  echo "Not ready yet... retry $i"
  sleep $((i*i))
done
echo "Publishing sample.html ..."
curl -sS -X POST "$BROKER/publish"   -H "Content-Type: multipart/form-data"   -F "bucket=${bucket}"   -F "region=${region}"   -F "key=sample.html"   -F "file=@$INDEX;type=text/html" || echo "sample publish skipped"
echo "Publishing env.js ..."
curl -sS -X POST "$BROKER/publish"   -H "Content-Type: multipart/form-data"   -F "bucket=${bucket}"   -F "region=${region}"   -F "key=assets/env.js"   -F "file=@$ENVJS;type=application/javascript" || echo "env.js publish skipped"
echo "Initial publish complete."
EOT
    interpreter = ["/bin/bash", "-c"]
    environment = {
      broker = ibm_code_engine_app.broker.endpoint
      bucket = ibm_cos_bucket.site.bucket_name
      region = var.region
      sample = "${path.module}/sample-app/sample.html"
      envjs  = "${path.module}/sample-app/assets/env.js"
    }
  }
}

output "primaryoutputlink" {
  value       = ibm_cos_bucket.site.website_endpoint
  description = "Public website endpoint (Primary Output -> /sample.html)"
}

output "push_api_url" { value = ibm_code_engine_app.broker.endpoint }

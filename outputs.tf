output "bucket_name" {
  value = ibm_cos_bucket.vibe_bucket.bucket_name
}

output "public_base_url" {
  value = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}"
}

output "vibe_ide_url" {
  value = "https://s3.${var.region}.cloud-object-storage.appdomain.cloud/${ibm_cos_bucket.vibe_bucket.bucket_name}/index.html"
}
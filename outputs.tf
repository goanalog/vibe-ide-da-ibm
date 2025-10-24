output "primaryoutputlink" {
  description = "Primary link to your live Vibe IDE (COS website)."
  value       = "https://${ibm_cos_bucket.vibe_bucket.bucket_name}.s3-web.${var.region}.cloud-object-storage.appdomain.cloud"
}

output "vibe_bucket_name" {
  value = ibm_cos_bucket.vibe_bucket.bucket_name
}
output "vibe_bucket_crn" {
  value = ibm_cos_bucket.vibe_bucket.crn
}
output "vibe_bucket_website_endpoint" {
  value = ibm_cos_bucket_website_configuration.vibe_bucket_website.website_endpoint
}
output "code_engine_url" {
  value = ibm_code_engine_app.vibe_app.endpoint
}
###############################################################################
# Outputs — Vibe IDE Deployable Architecture
###############################################################################

output "primaryoutputlink" {
  value       = ibm_cos_bucket_website_configuration.vibe_site.website_url
  description = "Vibe IDE URL"
}

output "vibe_bucket_website_endpoint" {
  value       = ibm_cos_bucket_website_configuration.vibe_site.website_url
  description = "COS Website Endpoint"
}

output "vibe_bucket_name" {
  value       = ibm_cos_bucket.vibe_bucket.bucket_name
  description = "COS Bucket Name"
}

output "vibe_bucket_website_endpoint" {
  value       = ibm_cos_bucket.vibe_bucket.website_endpoint
  description = "COS Website Endpoint"
}

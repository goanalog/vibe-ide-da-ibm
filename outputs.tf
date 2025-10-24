###############################################################################
# Outputs — Vibe IDE Deployable Architecture
###############################################################################

output "primaryoutputlink" {
  value       = "https://${ibm_cos_bucket.vibe_bucket.website_endpoint}"
  description = "Vibe IDE URL"
}

output "code_engine_url" {
  value       = ibm_code_engine_project.vibe_ce_project.status_url
  description = "Code Engine Backend URL"
}

output "vibe_bucket_name" {
  value       = ibm_cos_bucket.vibe_bucket.bucket_name
  description = "COS Bucket Name"
}

output "vibe_bucket_website_endpoint" {
  value       = ibm_cos_bucket.vibe_bucket.website_endpoint
  description = "COS Website Endpoint"
}

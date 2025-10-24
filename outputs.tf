
###############################################################################
# outputs.tf — Public URLs for Projects & Catalog
###############################################################################

output "primaryoutputlink" {
  description = "Website URL"
  value       = "https://${ibm_cos_bucket.vibe_bucket.bucket_name}.s3-website.${var.region}.cloud-object-storage.appdomain.cloud"
}

output "vibe_push_function_url" {
  description = "Public URL for the Vibe Push Function"
  value       = ibm_function_web_action.vibe_push_web.web_action_url
}

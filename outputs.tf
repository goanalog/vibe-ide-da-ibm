
###############################################################################
# outputs.tf
###############################################################################
output "primaryoutputlink" {
  description = "Website URL"
  value       = "https://${ibm_cos_bucket.vibe_bucket.bucket_name}.s3-website.${var.region}.cloud-object-storage.appdomain.cloud"
}

# Computed web action URL (no separate resource needed)
output "vibe_push_function_url" {
  description = "Public URL for the Vibe Push Function"
  value       = "https://${var.region}.functions.appdomain.cloud/api/v1/web/${ibm_function_namespace.vibe_ns.name}/default/${ibm_function_action.vibe_push.name}"
}

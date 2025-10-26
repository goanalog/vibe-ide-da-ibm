# Primary output: Public website URL
output "primary_output" {
  description = "Public Website URL for Vibe IDE"
  value       = ibm_cos_bucket_website.site.website_url
}

output "bucket_name" {
  value       = ibm_cos_bucket.site.bucket_name
  description = "Deployed COS bucket name"
}

output "cos_instance_name" {
  # Use the local variable to get the correct name
  value       = local.cos_instance_name
  description = "COS instance name"
}
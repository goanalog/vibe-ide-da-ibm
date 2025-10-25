output "primaryoutputlink" {
  value       = ibm_cos_bucket.site.website_endpoint
  description = "Public website endpoint"
}

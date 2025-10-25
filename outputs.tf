output "primaryoutputlink" {
  description = "Public URL to the live sample page"
  value       = local.primary_outputlink
}

output "push_api_url" {
  description = "If set, front-end Push 🚀 posts here. Leave empty to disable."
  value       = local.push_api_url
}
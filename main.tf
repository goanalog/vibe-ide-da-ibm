locals {
  vibe_ide_version = "1.3.4"
  name_prefix      = "vibe-ide-orb"
}

output "primaryoutputlink" {
  description = "Primary output link for the sample site"
  value       = var.primary_output != "" ? var.primary_output : "https://example.invalid/sample.html"
}

output "push_api_url" {
  description = "Code Engine broker publish endpoint"
  value       = var.push_api_url
}

variable "push_api_url" {
  type        = string
  description = "Public HTTPS endpoint of the Code Engine broker (/publish base)"
  default     = ""
}

variable "primary_output" {
  type        = string
  description = "Precomputed website endpoint (for zero-input experiences)"
  default     = ""
}

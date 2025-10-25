variable "region" {
  description = "IBM Cloud region"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Resource group"
  type        = string
  default     = "default"
}

variable "bucket_prefix" {
  description = "Prefix for generated bucket name"
  type        = string
  default     = "vibe-site"
}

variable "enable_public_read" {
  description = "Enable public-read policy for site content"
  type        = bool
  default     = true
}

variable "ce_image" {
  description = "Code Engine broker image (Node.js)"
  type        = string
  # Placeholder; CE App deploys with this image. Can be replaced in Catalog defaults.
  default     = "icr.io/codeengine/samples/http-to-cos:latest"
}

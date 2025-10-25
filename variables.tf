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
  description = "Prefix for generated bucket"
  type        = string
  default     = "vibe-site"
}
variable "enable_public_read" {
  description = "Enable public-read policy"
  type        = bool
  default     = true
}
variable "ce_image" {
  description = "Code Engine broker image (Node.js)"
  type        = string
  default     = "icr.io/codeengine/samples/http-to-cos:latest"
}

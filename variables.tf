variable "region" {
  description = "IBM Cloud region for the bucket (keep default for broad compatibility)."
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Resource group to use (kept internal / not surfaced in Catalog)."
  type        = string
  default     = "Default"
}

variable "project_url" {
  description = "Optional: deep link to the IBM Cloud Project that deployed this DA (used by the IDE's Push to Cloud button)."
  type        = string
  default     = ""
}

variable "prefix" {
  description = "Naming prefix for created resources."
  type        = string
  default     = "vibe"
}
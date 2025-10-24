variable "region" {
  description = "IBM Cloud region for resources (e.g., us-south)"
  type        = string
  default     = "us-south"
}

variable "resource_group_name" {
  description = "Name of the IBM Cloud resource group"
  type        = string
  default     = "Default"
}

variable "cos_instance_name" {
  description = "Name for the Cloud Object Storage instance"
  type        = string
  default     = "vibe-cos"
}

variable "bucket_name" {
  description = "COS bucket name (must be globally unique); leave empty to auto-generate"
  type        = string
  default     = ""
}

variable "function_namespace" {
  description = "Cloud Functions namespace to create or use"
  type        = string
  default     = "vibe-ns"
}

variable "function_action_name" {
  description = "Cloud Function action name"
  type        = string
  default     = "manifest-vibe"
}

variable "region" {
  description = "IBM provider region for ancillary services (not COS instance)"
  type        = string
  default     = "us-south"
}

variable "existing_cos_instance_id" {
  description = "Optional: The ID of an existing COS instance to use. If empty, a new 'lite' plan instance will be created."
  type        = string
  default     = ""
}

variable "cos_plan" {
  description = "Cloud Object Storage plan (lite|standard). For 1A we default to lite."
  type        = string
  default     = "lite"
  validation {
    condition     = contains(["lite", "standard"], lower(var.cos_plan))
    # This message is now a full sentence.
    error_message = "The cos_plan must be either 'lite' or 'standard'."
  }
}

variable "bucket_region" {
  description = "Region for the COS bucket (e.g., us-south, eu-de)."
  type        = string
  default     = "us-south"
}

variable "bucket_storage_class" {
  description = "COS storage class (smart, standard, vault, cold, flex, archive)."
  type        = string
  default     = "smart"
  validation {
    condition     = contains(["smart", "standard", "vault", "cold", "flex", "archive"], lower(var.bucket_storage_class))
    # This message is now a full sentence.
    error_message = "The bucket_storage_class must be one of: smart, standard, vault, cold, flex, or archive."
  }
}

variable "initial_html" {
  description = "Optional: Initial HTML to publish as index.html. Leave blank to use the bundled sample."
  type        = string
  default     = ""
  # The Projects UI will pass this as a string;
  # auto-escaped by HCL.
}

# Optional context vars that we are not surfacing in outputs for 3A, but keeping for provenance/extensions.
variable "project_id" {
  description = "IBM Cloud Project ID (context)."
  type        = string
  default     = ""
}

variable "config_id" {
  description = "IBM Cloud Projects configuration ID (context)."
  type        = string
  default     = ""
}
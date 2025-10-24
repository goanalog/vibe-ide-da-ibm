variable "region" {
  description = "IBM Cloud region for COS + objects (kept internal to the DA)."
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Resource group to use (kept internal to the DA)."
  type        = string
  default     = "Default"
}
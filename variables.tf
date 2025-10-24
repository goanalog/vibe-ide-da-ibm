
###############################################################################
# variables.tf — Module inputs
###############################################################################

variable "region" {
  description = "IBM Cloud region (e.g., us-south, eu-de)."
  type        = string
  default     = "us-south"
}

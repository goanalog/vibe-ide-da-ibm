variable "prefix" {
  description = "Name prefix for created resources"
  type        = string
  default     = "vibe"
}

variable "region" {
  description = "IBM Cloud region to deploy into"
  type        = string
  default     = "us-south"
}

variable "broker_image" {
  description = "Container image for the Vibe broker (e.g. docker.io/you/vibe-broker:latest)"
  type        = string
  default     = ""
}

###############################################################################
# Variables — Vibe IDE Deployable Architecture
###############################################################################

variable "region" {
  description = "IBM Cloud region for your deployment."
  type        = string
  default     = "us-south"
}

variable "slack_webhook_url" {
  description = "Optional Slack incoming webhook URL for deployment notifications."
  type        = string
  default     = ""
}

variable "slack_channel" {
  description = "Optional Slack channel (e.g. #vibe-alerts)."
  type        = string
  default     = ""
}

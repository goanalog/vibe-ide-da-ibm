variable "region" {
  description = "IBM Cloud region for COS and Code Engine."
  type        = string
  default     = "us-south"
}

# Optional Slack notifications (can be left blank)
variable "slack_webhook_url" {
  description = "Optional Slack incoming webhook URL for Vibe notifications."
  type        = string
  default     = ""
}
variable "slack_channel" {
  description = "Optional Slack channel name (e.g. #vibe-alerts)."
  type        = string
  default     = ""
}

# Project context (Projects UI can inject these automatically)
variable "ibm_project_id" {
  description = "IBM Cloud Project ID (auto-injected by Projects)."
  type        = string
  default     = ""
}
variable "ibm_project_name" {
  description = "IBM Cloud Project Name (auto-injected by Projects)."
  type        = string
  default     = ""
}
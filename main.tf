terraform {
  required_version = ">= 1.5.0"
  required_providers { ibm = { source = "ibm-cloud/ibm" version = ">= 1.80.0" } }
}
locals {
  primary_outputlink = "${var.primary_output_host}/${var.primary_output_path}"
  push_api_url       = var.push_api_url
}

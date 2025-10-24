output "bucket_name" {
  value       = ibm_cos_bucket.vibe_bucket.bucket_name
  description = "COS bucket name for the static starter files."
}

output "function_action_path" {
  value       = "${ibm_function_namespace.vibe_ns.name}/${ibm_function_action.vibe_push.name}"
  description = "Namespace/Action identifier for CLI invocation."
}

output "function_cli_invoke" {
  value       = "ibmcloud fn action invoke ${ibm_function_action.vibe_push.name} --namespace ${ibm_function_namespace.vibe_ns.name} --result"
  description = "Convenience CLI command to invoke the action and print JSON."
}

output "web_enable_hint" {
  value       = "To make a public web endpoint: ibmcloud fn action update ${ibm_function_action.vibe_push.name} --web true --namespace ${ibm_function_namespace.vibe_ns.name}"
  description = "Once enabled, the web URL will follow the standard /api/v1/web/{namespace}/default/{action}.json pattern."
}

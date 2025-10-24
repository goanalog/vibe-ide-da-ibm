output "bucket_name" { value = ibm_cos_bucket.vibe_bucket.bucket_name }
output "function_action_path" { value = "${ibm_function_namespace.vibe_ns.name}/${ibm_function_action.vibe_push.name}" }

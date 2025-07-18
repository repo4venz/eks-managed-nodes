output "mcp_service_name" {
  description = "Name of the MCP server service"
  value       = "mcp-server"
}

output "mcp_service_namespace" {
  description = "Namespace of the MCP server service"
  value       = var.namespace
}

output "mcp_service_endpoint" {
  description = "Endpoint for the MCP server service"
  value       = "https://${var.ingress_host}"  
}

output "pod_identity_role_arn" {
  description = "ARN of the IAM role for pod identity"
  value       = aws_iam_role.pod_identity_role_mcp_server.arn
}
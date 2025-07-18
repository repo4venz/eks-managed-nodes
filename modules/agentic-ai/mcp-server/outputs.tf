output "mcp_service_name" {
  description = "Name of the MCP server service"
  value       = kubernetes_service_v1.mcp_service.metadata[0].name
}

output "mcp_service_namespace" {
  description = "Namespace of the MCP server service"
  value       = kubernetes_namespace_v1.mcp_namespace.metadata[0].name
}

output "mcp_service_endpoint" {
  description = "Endpoint for the MCP server service"
  value       = "https://${var.ingress_host}"
}

output "mcp_service_internal_endpoint" {
  description = "Internal cluster endpoint for the MCP server service"
  value       = "http://${kubernetes_service_v1.mcp_service.metadata[0].name}.${kubernetes_namespace_v1.mcp_namespace.metadata[0].name}.svc.cluster.local:${var.mcp_port}"
}

output "pod_identity_role_arn" {
  description = "ARN of the IAM role for pod identity"
  value       = aws_iam_role.pod_identity_role_mcp_server.arn
}
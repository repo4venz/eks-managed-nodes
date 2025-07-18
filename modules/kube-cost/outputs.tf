 
 

# modules/kubecost/outputs.tf
output "irsa_role_arn" {
  description = "ARN of the IAM role for Kubecost"
  value       = aws_iam_role.kubecost.arn
}

output "service_account_name" {
  description = "Kubecost service account name"
  value       = var.service_account_name
}

output "namespace" {
  description = "Namespace where Kubecost is deployed"
  value       = var.namespace
}

output "ingress_host" {
  description = "Kubecost ingress hostname"
  value       = "https://${var.ingress_host}"  
}
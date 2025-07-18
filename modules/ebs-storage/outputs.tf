output "ebs_storage_class_name" {
  description = "Name of the EBS storage class"
  value       = kubernetes_storage_class_v1.ebs_sc.metadata[0].name
}

output "ebs_storage_class_retain_name" {
  description = "Name of the EBS storage class with retain policy"
  value       = kubernetes_storage_class_v1.ebs_sc_retain.metadata[0].name
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EBS CSI driver"
  value       = aws_iam_role.ebs_csi_driver_role.arn
}
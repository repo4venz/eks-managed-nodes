output "efs_storage_class_name" {
  description = "Name of the EFS storage class"
  value       = kubernetes_storage_class_v1.efs_sc.metadata[0].name
}

output "efs_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.eks_efs.id
}

output "efs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EFS CSI driver"
  value       = aws_iam_role.efs_csi_driver_role.arn
}
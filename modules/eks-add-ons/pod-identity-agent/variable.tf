variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
 variable eks_worker_nodes_role_arn {
  description = "The ARN of the IAM role associated with the EKS worker nodes"
  type        = string
  default     = ""
 }
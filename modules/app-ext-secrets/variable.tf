variable "k8s_cluster_name" {
  description = "EKS cluster name"
  type        = string
}


 

variable "aws_test_secrets" {
  type = list(object({
    secret_name           = string
    application_namespace = string
    k8s_secret_store_name = string
  }))
  default = []
  description = "List of Secrets of AWS Secrets Manager and Kubernetes Application Namespace. It will map the which secrets will be accessed from which namespace"
   
}


variable "app_namespace" {
  description = "Business Application Namespaces"
  type        = list(string)
  default     = ["myapps1", "myapps2"]
}
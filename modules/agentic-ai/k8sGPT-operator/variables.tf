variable "environment" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default = "dev"
}


 
variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

 

variable "k8sgpt_namespace" {
  description = "Kubernetes namespace for k8sgpt"
  type        = string
  default     = "k8sgpt-operator-system"
}


variable k8sgpt_service_account_name {
  description = "Service account name for k8sgpt"
  type        = string
  default     = "k8sgpt-k8sgpt-operator-system"  # This is the default service account name created by the k8sgpt Helm chart
}

variable k8sgpt_helm_version {
  description = "Version of the k8sgpt Helm chart"
  type        = string
  default     = "0.2.22"
}
 
variable prometheus_namespace {
  description = "Kubernetes namespace for Prometheus"
  type        = string
  default     = "monitoring"
}

variable "ai_foundation_model_service" {
  description = "Service for AI foundation model (e.g., bedrock)"
  type        = string
  default     = "bedrock"
}
variable "ai_foundation_model_name" {
  description = "Name of the AI foundation model (e.g., anthropic.claude-v2)"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20240620-v1:0"
}
variable "ai_foundation_model_region" {
  description = "Region for the AI foundation model service"
  type        = string
  default     = "eu-central-1"
} 
 
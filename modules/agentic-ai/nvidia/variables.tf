variable "environment" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default = "dev"
}


variable "nvidia_plugin_namespace" {
  description = "Kubernetes namespace for NVIDIA device plugin"
  type        = string
  default     = "agentic-ai"
}
variable "nvidia_service_account_name" {
  description = "Name of the service account for NVIDIA device plugin"
  type        = string
  default     = "nvidia-device-sa"
}

variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable nvidia_device_plugin_helm_version {
  description = "Version of the NVIDIA device plugin Helm chart"
  type        = string
  default     = "0.14.1"
}

  

variable "nvidia_dcgm_exporter_helm_version" {
  description = "Version of the NVIDIA DCGM Exporter Helm chart"
  type        = string
  default     = "3.1.8" # Use the latest stable version
}

variable prometheus_namespace {
  description = "Kubernetes namespace for Prometheus"
  type        = string
  default     = "monitoring"
}


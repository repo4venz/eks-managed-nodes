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

variable "k8sgpt_namespace" {
  description = "Kubernetes namespace for k8sgpt"
  type        = string
  default     = "k8sgpt-operator-system1"
}


variable k8sgpt_service_account_name {
  description = "Service account name for k8sgpt"
  type        = string
  default     = "k8sgpt-operator-sa1"
}

variable ingress_host {
  description = "Ingress host for k8sgpt"
  type        = string
  default     = "k8sgpt.suvendupublicdomain.fun" # Replace with your actual domain
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

variable install_nvidia_device_plugin {
  description = "Flag to install NVIDIA device plugin"
  type        = bool
  default     = false
}
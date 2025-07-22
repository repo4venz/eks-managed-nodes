variable "environment" {}
variable "cluster_name" {}

variable "cluster_group" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnets_cidr" {}
variable "availability_zones_public" {}
variable "private_subnets_cidr" {}
variable "availability_zones_private" {}
variable "cidr_block_internet_gw" {}
variable "cidr_block_nat_gw" {}

 
variable "cluster_version" {}
variable "region_name" {
  description = "AWS Region code"
  default = "eu-west-2"
}
variable "user_profile" {
  description = "AWS User profile to execute commands"
  default = "default"
}
variable "user_os" {
  description = "Operating system used by user to execute Terraform, Kubectl, aws commands. e.g. \"windows\" or \"linux\""
}
 
 
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags e.g. `map('BusinessUnit`,`XYZ`)"
}


 variable "public_domain_name" {
  description = "Public Domain name hosted in Route53. e.g. suvendupublicdomain.fun"
  type        = string
  default = ""
}


variable include_mcp_server_module {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "mcpserver_chart_version" {
  type        = string
  description = "Helm chart version for MCP server"
  default     = "0.1.0"
  
}

variable include_k8sGPT_module {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "nvidia_device_plugin_helm_version" {
  type        = string
  description = "Helm chart version for NVIDIA device plugin"
  default     = "0.14.1"
}
variable "k8sgpt_helm_version" {
  type        = string
  description = "Helm chart version for k8sgpt"
  default     = "0.2.22"
}
variable "nvidia_plugin_namespace" {
  description = "Kubernetes namespace for NVIDIA device plugin"
  type        = string
  default     = "agentic-ai"
}

variable "nvidia_device_plugin_enabled" {
  description = "Flag to enable NVIDIA device plugin installation"
  type        = bool
  default     = false
}
variable "k8sgpt_namespace" {
  description = "Kubernetes namespace for k8sgpt"
  type        = string
  default     = "k8sgpt-operator-system"
}

variable install_nvidia_device_plugin {
  description = "Flag to install NVIDIA device plugin"
  type        = bool
  default     = false
}
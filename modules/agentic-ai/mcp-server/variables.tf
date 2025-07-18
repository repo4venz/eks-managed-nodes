variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

 
variable "helm_repo_url" {
  description = "Helm repository URL for MCP server chart"
  type        = string
  default     = "https://aws.github.io/eks-charts"
}

variable "mcp_server_chart_version" {
  description = "Version of the Helm chart for MCP server"
  type        = string
  default     = "0.1.0"
}

variable "mcp_image_repo" {
  description = "Docker image repository for MCP server"
  type        = string
  default     = "public.ecr.aws/aws-mcp/mcp-server"
}

variable "mcp_image_tag" {
  description = "Docker image tag for MCP server"
  type        = string
  default     = "latest"
}

variable "mcp_port" {
  description = "Port for MCP server"
  type        = number
  default     = 8080
}

variable "mcp_replicas" {
  description = "Number of MCP server replicas"
  type        = number
  default     = 2
}

variable "mcp_cpu_request" {
  description = "CPU request for MCP server"
  type        = string
  default     = "500m"
}

variable "mcp_memory_request" {
  description = "Memory request for MCP server"
  type        = string
  default     = "512Mi"
}
variable "mcp_cpu_limit" {
  description = "CPU limit for MCP server"
  type        = string
  default     = "1"
}
variable "mcp_memory_limit" {
  description = "Memory limit for MCP server"
  type        = string
  default     = "1Gi"
}

variable "policy_arns" {
  description = "List of policy ARNs to attach to the role"
  type        = list(string)
  default = [
          "arn:aws:iam::aws:policy/IAMFullAccess",
          "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
          "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  ]
}


variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "agentic-ai"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "mcp-server-sa"
}

variable "ingress_host" {
  description = "Hostname for the ingress"
  type        = string
  default = "mcpserver.suvendupublicdomain.fun"
}

variable "environment" {
  description = "Environemnt of MCP Server"
  type        = string
  default = "dev"
}
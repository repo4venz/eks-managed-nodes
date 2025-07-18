variable "k8s_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for MCP server"
  type        = string
  default     = "agentic-ai"
}

variable "service_account_name" {
  description = "Name of the service account for MCP server"
  type        = string
  default     = "mcp-server-sa"
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
  default     = "1000m"
}

variable "mcp_memory_limit" {
  description = "Memory limit for MCP server"
  type        = string
  default     = "1Gi"
}


variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable policy_arns {
  description = "List of IAM policy ARNs to attach to the MCP server IAM role"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess"
  ]
}

variable "ingress_host" {
  description = "Hostname for MCP server ingress"
  type        = string
  default = "mcpserver.suvendupublicdomain.fun"
}
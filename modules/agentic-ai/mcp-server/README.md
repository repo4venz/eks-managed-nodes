# Model Context Protocol (MCP) Server for EKS using Helm

This module deploys a Model Context Protocol (MCP) server on an Amazon EKS cluster using Terraform and Helm.

## Features

- Deploys MCP server using Helm chart for easier management
- Sets up necessary IAM roles and policies using EKS Pod Identity
- Creates Kubernetes service for internal cluster access
- Configurable resource requests and limits
- Customizable Helm chart values

## Usage

```hcl
module "agentic_ai" {
  source           = "./modules/agentic-ai"
  k8s_cluster_name = var.cluster_name
  
  # Helm chart configuration
  helm_repo_url     = "https://aws.github.io/eks-charts"
  helm_chart_version = "0.1.0"
  
  # MCP server configuration
  mcp_image_repo    = "public.ecr.aws/aws-mcp/mcp-server"
  mcp_image_tag     = "latest"
  mcp_port          = 8080
  mcp_replicas      = 2
  mcp_cpu_request   = "500m"
  mcp_memory_request = "512Mi"
}
```

## Requirements

- AWS EKS cluster with Pod Identity enabled
- Kubernetes provider configured with access to the EKS cluster
- Helm provider configured with access to the EKS cluster
- AWS provider configured with appropriate permissions

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| k8s_cluster_name | Name of the EKS cluster | string | n/a | yes |
| helm_repo_url | Helm repository URL for MCP server chart | string | "https://aws.github.io/eks-charts" | no |
| helm_chart_version | Version of the Helm chart for MCP server | string | "0.1.0" | no |
| mcp_image_repo | Docker image repository for MCP server | string | "public.ecr.aws/aws-mcp/mcp-server" | no |
| mcp_image_tag | Docker image tag for MCP server | string | "latest" | no |
| mcp_port | Port for MCP server | number | 8080 | no |
| mcp_replicas | Number of MCP server replicas | number | 2 | no |
| mcp_cpu_request | CPU request for MCP server | string | "500m" | no |
| mcp_memory_request | Memory request for MCP server | string | "512Mi" | no |

## Outputs

| Name | Description |
|------|-------------|
| mcp_service_endpoint | Endpoint for the MCP server service |
| pod_identity_role_arn | ARN of the IAM role for pod identity |

## Accessing the MCP Server

Once deployed, the MCP server can be accessed within the cluster at:

```
mcp-server.agentic-ai.svc.cluster.local:8080
```

For applications that need to use the MCP server, configure them to connect to this endpoint.
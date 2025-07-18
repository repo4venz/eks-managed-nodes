provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Add the storage module for EBS CSI driver and storage classes
module "storage" {
  source           = "./modules/storage"
  k8s_cluster_name = var.cluster_name
  
  depends_on = [
    # Add your EKS cluster module dependency here
    # For example: module.eks
  ]
}

# Add the agentic-ai module for MCP server
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
  
  depends_on = [
    module.storage
    # Add your EKS cluster module dependency here
    # For example: module.eks
  ]
}
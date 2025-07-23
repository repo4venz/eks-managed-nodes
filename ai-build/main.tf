# agentic-ai/main.tf
# This file contains the main configuration for the Agentic AI modules.
 
 # Add the agentic-ai module for MCP server
module "mcp_server" {
   count = var.include_mcp_server_module ? 1 : 0

  source = "../modules/agentic-ai/mcp-server"
  k8s_cluster_name = local.k8s_cluster_name
  # Helm chart configuration
  environment               =  var.environment
  ingress_host              =  "mcpserver.${var.public_domain_name}"
  
 # depends_on = [ module.external-dns, module.lets-encrypt]
}
 

  
 
 # Add the agentic-ai module for k8sGPT
module "k8sGPT-operator" {
   count = var.include_k8sGPT_module ? 1 : 0

  source = "../modules/agentic-ai/k8sGPT-operator"
  k8s_cluster_name = local.k8s_cluster_name
  # Helm chart configuration
  environment                  =  var.environment
  k8sgpt_helm_version               = var.k8sgpt_helm_version
  ai_foundation_model_service  = var.ai_foundation_model_service
  ai_foundation_model_region   = var.ai_foundation_model_region
  ai_foundation_model_name     = var.ai_foundation_model_name
  
  #depends_on = [ module.external-dns, module.lets-encrypt]
}
 

 module "nvidia-plugin" {
   count = var.include_nvidia_gpu_module ? 1 : 0

  source = "../modules/agentic-ai/nvidia"
  k8s_cluster_name = local.k8s_cluster_name
  # Helm chart configuration
  environment                       =  var.environment
  nvidia_device_plugin_helm_version = var.nvidia_device_plugin_helm_version
  nvidia_dcgm_exporter_helm_version = var.nvidia_dcgm_exporter_helm_version
  
  #depends_on = [ module.external-dns, module.lets-encrypt]
}
 
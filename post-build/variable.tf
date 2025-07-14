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

variable aws_admin_role_name {
  description = "AWS Admin Role to manage EKS cluster. The role must be created in AWS with required permission."
  default = "eks_admin_role"
}
variable aws_admin_user_name {
  description = "AWS User who will assume AWS Admin Role to manage EKS cluster. The user must be created in AWS to assume the admin role."
  default = "eks_admin_user"
}

variable "app_namespace" {
  description = "Business Application Namespaces"
  type        = list(string)
  default     = ["myapps1", "myapps2"]
}
 
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

variable "github_runner_base_path" {
  description = "GitHub Actions Runner Base path for Linux"
  type = string
  default = "/home/runner/"
}

 
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags e.g. `map('BusinessUnit`,`XYZ`)"
}


variable "include_nginx_controller_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "include_eks_cluster_autoscaler_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_external_dns_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_metrics_server_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_fluentbit_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_ebs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}

variable "include_efs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}

variable "include_prometheus_module" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}

variable "include_k8s_app_module" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_kubecost_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "k8s_namespace" {
  type    = string
  default = "kube-system"
}

variable "k8s_observability_namespace" {
  type    = string
  default = "monitoring"
}

variable "nginx_ingress_chart_version" {
  type        = string
  description = "Helm chart version for Ingress nginx LB controller"
  default     = "4.12.3"
}

variable "fluentbit_chart_version" {
  type        = string
  description = "Helm chart version for Ingress nginx LB controller"
  default     = "0.1.35"
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Helm chart version for K8s Metrics Server"
  default     = "3.12.1"
}

variable "prometheus_chart_version" {
  type        = string
  description = "Helm chart version for kube-prometheus-stack"
  default     = "75.10.0"
}

variable "spot_instance_types" {
  description = "EKS worker nodes Spot instance types"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3.small"]
}

variable "ondemand_instance_types" {
  description = "EKS worker nodes On-Demand instance types"
  type        = list(string)
  default     = ["t2.medium", "t2.large", "t2.small"]
}

variable "required_spot_instances" {
  description = "EKS worker nodes Spot instance types"
  type        = bool
  default     = true
}


variable "required_ondemand_instances" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = false
}

variable "base_scaling_config_spot" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }
}


variable "scaling_config_ondemand" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 2
    max_size     = 6
    min_size     = 1
  }
}

variable "ebs_volume_size_in_gb" {
  type        = number
  description = "EKS Worker Node EBS Volume Size for SPOT and On_DEMAND instances"
  default     = 20
}

variable "ebs_volume_type" {
  type        = string
  description = "EKS Worker Node EBS Volume Type for SPOT and On_DEMAND instances"
  default     = "gp3"
}

variable "kubecost_chart_version" {
  type        = string
  description = "Helm chart version for kube-cost"
  default     = "2.8.0"
}

variable "certmanager_chart_version" {
  type        = string
  description = "Helm chart version for kube-cost"
  default     = "1.18.2"
}


variable "include_cert_manager_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_lets_encrypt_ca_module" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_k8s_app_secured_module" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "acme_environment" {
  description = "Environment of CME Lets Encrypt for certificate"
  type        = string
  default = "prod"
}

variable "include_vpc_cni_addon_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "public_domain_name" {
  description = "Public Domain name hosted in Route53. e.g. suvendupublicdomain.fun"
  type        = string
  default = ""
}


variable "external_secret_chart_version" {
  type        = string
  description = "Helm chart version for external-secrets"
  default     = "0.18.2"
}

variable "include_external_secrets_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
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
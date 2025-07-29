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

variable aws_admin_role_names {
  description = "AWS Admin Role to manage EKS cluster. The role must be created in AWS with required permission."
  type = list(string)
  default     = []
}
variable aws_admin_user_names {
  description = "AWS User who will assume AWS Admin Role to manage EKS cluster. The user must be created in AWS to assume the admin role."
  type = list(string)
  default     = []
}

variable "enable_eks_access_entries_only" {
  type        = bool
  default     = false
  description = "When false, it will use EKS ConfigMap and Access Entries both. When true, it will only use EKS Access Entries. EKS Authentication methods supports both - ConfigMap and Access Entries."
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

 
variable "include_ebs_csi_driver" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}

variable "include_efs_csi_driver_addon" {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}
 

variable  include_ebs_csi_driver_module {
  description = "Execute module/feature or not. true = execute and false = don't execute"
  type        = bool
  default     = true
}

variable  include_efs_csi_driver_module {
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


variable "include_calico_module" {
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
  default     = "55.5.0"
}

variable "calico_chart_version" {
  type        = string
  description = "Helm chart version for Calico"
  default     = "3.30.2"
}

variable "ebs_csi_helm_chart_version" {
  description = "Helm chart version for EBS CSI Driver"
  type        = string
  default     = "2.46.0"  # Check for latest version
}

variable efs_csi_helm_chart_version {
  description = "Helm chart version for EFS CSI Driver"
  type        = string
  default     = "2.4.0"  # Check for latest version  
}

variable "spot_instance_types" {
  description = "EKS worker nodes Spot instance types"
  type        = list(string)
  default     = [ "t3.large", "t3.xlarge", "t3.2xlarge" ]
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

variable "enable_spot_pod_density_customised" {
  description = "EKS worker nodes Spot instance types"
  type        = bool
  default     = false
}

variable "enable_ondemand_pod_density_customised" {
  description = "EKS worker nodes On-Demand instance types"
  type        = bool
  default     = false
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


variable "base_scaling_config_ondemand" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 1
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

 variable enable_vpc_cni_advance_network {
  default = false
  type = bool
  description = "Enable / Disable VPC CNI Advance networking using prefix delegation or IP target"
 }


variable "vpc_cni_prefix_delegation_configs" {
  type = object({
    enable_prefix_delegation = string
    warm_eni_target     = string
    warm_prefix_target  = string
    warm_ip_target      = string
    minimum_ip_target   = string
  })
  description = "VPC CNI Advance networking configs"
  default = {
    enable_prefix_delegation = "true"   
    warm_eni_target     = "1"
    warm_prefix_target  = "1"   # Warm up 1 prefix
    warm_ip_target      = "0"   # Warm up n IPs.
    minimum_ip_target   = "0"
  }
}
 

variable "increase_spot_pod_density" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
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

variable "include_kube_proxy_addon_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}

variable "include_coredns_addon_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable include_pod_identity_agent_addon_module {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}
 
variable "max_pods" {
  description = "Map of instance type to max pods"
  type        = map(number)

  default = {
    "t3.large"    = 35
    "t3.xlarge"   = 58
    "t3.2xlarge"  = 58
    "r5.8xlarge"  = 234
    "c5.4xlarge"  = 234
    "m5.large"    = 29
    "m5.xlarge"   = 58
    "m5.2xlarge"  = 110
    "m5.4xlarge"  = 234
    "m5.8xlarge"  = 234
  }
}


variable "overrides_spot_node_scale_config" {
  description = "Per-instance-type overrides for SPOT instances. Overrided local variable with different scaling configs."
  type = map(object({
    desired_size = optional(number)
    min_size     = optional(number)
    max_size     = optional(number)
    max_pods     = optional(number)
  }))
  default = {
    "t3.xlarge" = {
      desired_size = 3
    }
    "c5.4xlarge" = {
      desired_size = 1
      max_size     = 5
      max_pods     = 234
    }
  }
}

variable "increase_ondemand_pod_density" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "overrides_ondemand_node_scale_config" {
  description = "Per-instance-type overrides for ON-DEMAND instances. Overrided local variable with different scaling configs."
  type = map(object({
    desired_size = optional(number)
    min_size     = optional(number)
    max_size     = optional(number)
    max_pods     = optional(number)
  }))
  default = {
    "t3.xlarge" = {
      desired_size = 3
    }
    "c5.4xlarge" = {
      desired_size = 1
      max_size     = 5
      max_pods     = 234
    }
  }
}

variable required_gpu_ondemand_instances {
  description = "Flag to indicate if LLM instances are required"
  type        = bool
  default     = false
}

variable required_gpu_spot_instances {
  description = "Flag to indicate if LLM instances are required"
  type        = bool
  default     = false
}

variable loki_chart_version {
  type        = string
  description = "Helm chart version for Loki"
  default     = "6.32.0"
}

  
variable promtail_chart_version  {
    type        = string
  description = "Helm chart version for Promtail"
  default     = "6.17.0"
}



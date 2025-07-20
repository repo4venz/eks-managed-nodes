# EKS Cluster and Network Infrastructure
environment                  =  "dev"
#user_profile                 =  "AWS_741032333307_User"
user_os                      =  "linux"
cluster_name                 =  "eks-managed-clstr"
cluster_version              =  "1.33"
cluster_group                =  "eks-managed-nodes"
vpc_cidr                     =  "192.168.0.0/16"
vpc_name                     =  "eks-vpc"
public_subnets_cidr          =  ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
private_subnets_cidr         =  ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
region_name                  =  "eu-west-2"
availability_zones_public    =  ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
availability_zones_private   =  ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
cidr_block_internet_gw       =  "0.0.0.0/0"
cidr_block_nat_gw            =  "0.0.0.0/0"
aws_admin_role_name          = "suvendu-super-admin-role"
aws_admin_user_name          = "suvendu_admin_user"
#github_runner_base_path      = "/home/runner/"
k8s_observability_namespace  = "monitoring"
nginx_ingress_chart_version  = "4.12.3"
fluentbit_chart_version      = "0.1.35"
metrics_server_chart_version = "3.12.1"
prometheus_chart_version     = "75.10.0"
kubecost_chart_version       = "2.8.0"
certmanager_chart_version    = "1.18.2"
external_secret_chart_version = "0.18.2"
ebs_csi_helm_chart_version = "2.46.0"
efs_csi_helm_chart_version = "2.4.0"
mcpserver_chart_version     = "0.1.0"
external_dns_chart_version = "1.17.0"


app_namespace        =  ["myapps1", "myapps2"]
aws_test_secrets               = [
                                    {
                                        secret_name = "test/application3/credentials",          # Reference to the secret of AWS Secret Manager 
                                        application_namespace = "myapps1"                # K8s namespace in EKS where the AWS Secret will sync
                                    },
                                    {
                                        secret_name = "test/application4/credentials",
                                        application_namespace = "myapps2"
                                    }
                                ]

include_vpc_cni_addon_module = true
include_kube_proxy_addon_module = true
include_coredns_addon_module = true
include_pod_identity_agent_addon_module = true
#include_ebs_csi_driver = true
#include_efs_csi_driver_addon = true
include_ebs_csi_driver_module = true
include_efs_csi_driver_module = true


include_calico_module = false
include_nginx_controller_module = true
include_eks_cluster_autoscaler_module = true
include_external_dns_module = true
include_metrics_server_module = true
include_fluentbit_module = false
include_prometheus_module = true

include_cert_manager_module = true
include_lets_encrypt_ca_module = true   
include_k8s_app_module = false
include_k8s_app_secured_module = true  
include_kubecost_module = false    
include_external_secrets_module = false
application-external-secrets_module = false









####################  EKS Worker Nodes configs - Works with VPC CNI (Generic Config for multiple type of instances) ###################

# ------  Common for SPOT and On-DEMAND -----#
ebs_volume_size_in_gb        =  20
ebs_volume_type              =  "gp3"

#----------- SPOT Node Group Configs with mixed EC2 types  --------------#
#-----------------------------------------------------------------------------

required_spot_instances      =  true   # either spot or ondemand or both instance types provision for eks worker nodes
spot_instance_types          =  [ "t3.xlarge", "t3.2xlarge", "m5.2xlarge" ]
increase_spot_pod_density    =  true   # applicable only when (required_spot_instances=true) for SPOT Node Group with mixed EC2 types. All EC2 instances POD density will be increased upto max

# ---- Common SPOT Node Scaling Configs ----- #
base_scaling_config_spot = {
  desired_size = 1
  max_size     = 20
  min_size     = 1
}

# ----- Invidual Node group per Instance wise with user provided high POD density in EKS Nodes ----#
enable_spot_pod_density_customised  =  false  # This will ignore 'required_spot_instances' and use 'spot_instance_types' to create individual node groups based on EC2 types


# ---- Overrriding SPOT Node Scaling Configs ----- #
# Applicable only when 'enable_spot_pod_density_customised' = true
overrides_spot_node_scale_config = {
  "t3.xlarge" = {
    min_size     = 1
    desired_size = 1
    max_size     = 5
  },
  "t3.2xlarge" = {
    min_size     = 1
    desired_size = 1
    max_size     = 10
    max_pods     = 100   
  },
  "m5.2xlarge" = {
    max_pods = 100   
  }
}



#----------- ON-DEMAND Node Group Configs --------------#
#--------------------------------------------------------------

required_ondemand_instances   =  false   # either spot or ondemand or both instance types provision for eks worker nodes
ondemand_instance_types       =  ["t3.medium", "m5.large", "t3.xlarge"]
increase_ondemand_pod_density = false  # applicable only when (required_ondemand_instances=true) for ON-DEMAND Node Group with mixed EC2 types. All EC2 instances POD density will be increased upto max

# ---- Common ON-DEMAND Node Scaling Configs ----- #

base_scaling_config_ondemand = {
  desired_size = 1
  max_size     = 10
  min_size     = 1
}

# ----- Invidual Node group per Instance wise with user provided high POD density in EKS Nodes ----#
enable_ondemand_pod_density_customised  =  false  # This will ignore 'required_ondemand_instances' and use 'ondemand_instance_types' to create individual node groups based on EC2 types


# ---- Overrriding ON-DEMAND Node Scaling Configs ----- #
# Applicable only when 'enable_ondemand_pod_density_customised' = true
overrides_ondemand_node_scale_config = {
  "t3.medium" = {
    min_size     = 1
    desired_size = 1
    max_size     = 5
  },
  "t3.xlarge" = {
    min_size     = 1
    desired_size = 1
    max_size     = 10
    max_pods     = 30   
  },
  "m5.large" = {
    max_pods = 50   
  }
}


##################### Agentic AI LLM - EKS Worker Nodes Configs ####################

include_mcp_server_module = false
required_llm_ondemand_instances = false
required_llm_spot_instances = false


####################  END of EKS Worker Nodes configs with VPC CNI ###################

public_domain_name = "suvendupublicdomain.fun"
 

 


 
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


app_namespace        =  ["myapps1", "myapps2"]
aws_test_secrets               = [
                                    {
                                        secret_name = "test/application3/credentials",          # Reference to the secret of AWS Secret Manager 
                                        application_namespace = "myapps1"                # K8s namespace in EKS where the AWS Secret will sync
                                        k8s_secret_store_name = "application1-secret-store"     # K8s Secret Store name which will be created in EKS to sync the AWS Secrets
                                    },
                                    {
                                        secret_name = "test/application4/credentials",
                                        application_namespace = "myapps2"
                                        k8s_secret_store_name = "application2-secret-store" 
                                    }
                                ]

include_vpc_cni_addon_module = true
include_calico_module = true
include_nginx_controller_module = true
include_eks_cluster_autoscaler_module = true
include_external_dns_module = true
include_metrics_server_module = true
include_fluentbit_module = true
include_prometheus_module = true
include_ebs_csi_driver_addon = true
include_efs_csi_driver_addon = true
include_cert_manager_module = true
include_lets_encrypt_ca_module = true  # Run as post build
include_k8s_app_module = true
include_k8s_app_secured_module = true  
include_kubecost_module = true   # Run as post build
include_external_secrets_module = true # Run as post build





#EKS Worker Nodes config (Geric Config for multiple type of instances)
spot_instance_types          =  [ "t3.xlarge", "t3.2xlarge", "m5.2xlarge" ]
ondemand_instance_types      =  ["t3.medium", "m5.large", "t3.xlarge"]
required_spot_instances      =  true   # either spot or ondemand or both instance types provision for eks worker nodes
required_ondemand_instances  =  false   # either spot or ondemand or both instance types provision for eks worker nodes
required_spot_instances_max_pods      =  false 

ebs_volume_size_in_gb        =  20
ebs_volume_type              =  "gp3"

scaling_config_spot = {
  desired_size = 3
  max_size     = 20
  min_size     = 2
}

scaling_config_ondemand = {
  desired_size = 5
  max_size     = 10
  min_size     = 1
}

public_domain_name = "suvendupublicdomain.fun"

  /*

  # Node group configurations (workes with VPC CNI only)
  node_groups = {
    general_large = {
      instance_type = "t3.large"
      desired_size  = 2
      max_size     = 20
      min_size     = 2
      max_pods      = local.max_pods["t3.large"]
    }
    general_xlarge= {
      instance_type = "t3.xlarge"
      desired_size  = 2
      max_size     = 20
      min_size     = 2
      max_pods      = local.max_pods["t3.xlarge"]
    }
    general_2xlarge= {
      instance_type = "t3.2xlarge"
      desired_size  = 2
      max_size     = 20
      min_size     = 2
      max_pods      = local.max_pods["t3.2xlarge"]
    }
    high_mem = {
      instance_type = "r5.8xlarge"
      desired_size  = 1
      max_size     = 20
      min_size     = 2
      max_pods      = local.max_pods["r5.8xlarge"]
    }
    high_cpu = {
      instance_type = "c5.4xlarge"
      desired_size  = 1
      max_size     = 20
      min_size     = 2
      max_pods      = local.max_pods["c5.4xlarge"]
    }
  }
  */
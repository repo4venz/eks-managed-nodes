# EKS Cluster and Network Infrastructure
environment                  =  "dev"
#user_profile                 =  "AWS_741032333307_User"
user_os                      =  "linux"
cluster_name                 =  "eks-managed-clstr"
cluster_version              =  "1.33"
cluster_group                =  "eks-managed-nodes"
spot_instance_types          =  ["t3.medium", "t3.large", "t3.small"]
ondemand_instance_types      =  ["t2.medium", "t2.large", "t2.small"]
required_spot_instances      =  true   # either spot or ondemand or both instance types provision for eks worker nodes
required_ondemand_instances  =  true   # either spot or ondemand or both instance types provision for eks worker nodes
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
fluentbit_chart_version      = "0.50.0"
metrics_server_chart_version = "3.12.1"
prometheus_chart_version     = "55.5.0"
app_namespace        =  ["myapps1", "myapps2"]
aws_sm_secrets               = [
                                    {
                                        secret_name = "test/application1/credentials",          # Reference to the secret of AWS Secret Manager 
                                        application_namespace = "ns-application"                # K8s namespace in EKS where the AWS Secret will sync
                                        k8s_secret_store_name = "application1-secret-store"     # K8s Secret Store name which will be created in EKS to sync the AWS Secrets
                                    },
                                    {
                                        secret_name = "test/application2/credentials",
                                        application_namespace = "ns-application"
                                        k8s_secret_store_name = "application2-secret-store" 
                                    }
                                ]


include_nginx_controller_module = true
include_eks_cluster_autoscaler_module = true
include_external_dns_module = true
include_metrics_server_module = true
include_fluentbit_module = true
include_prometheus_module = true
include_ebs_csi_driver_addon = true
include_efs_csi_driver_addon = true
include_k8s_app_module = true


/*
include_fluentbit_module = true
include_coredns_patching_module = true
include_alb_controller_module = true
include_kubernetes_addons_module = true
include_appmesh_controller_module = false
include_metrics_server_module = true
include_external_secrets_module = false
include_external_secrets_multiple_module = false
include_external_dns_module = false
include_k8s_app_helm_module = false
include_k8s_app_module = false
*/



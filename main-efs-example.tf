module "efs_storage" {
  source = "./modules/efs-storage"
  
  cluster_name                  = var.cluster_name
  vpc_id                        = var.vpc_id
  private_subnet_ids            = var.private_subnet_ids
  eks_cluster_security_group_id = var.eks_cluster_security_group_id
}
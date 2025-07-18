resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-gp3-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
    encrypted = "true"
    iops      = var.ebs_volume_iops
    throughput = var.ebs_volume_throughput
    type      = var.ebs_volume_type
    encrypted = "true"
    kmsKeyId = var.eks_kms_secret_encryption_alias_arn
  }

}

resource "kubernetes_storage_class" "ebs_sc_retain" {
  metadata {
    name = "ebs-gp3-sc-retain"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy = "Retain"
  allow_volume_expansion = true
  
  parameters = {
    type = "gp3"
    encrypted = "true"
    iops      = var.ebs_volume_iops
    throughput = var.ebs_volume_throughput
    type      = var.ebs_volume_type
    encrypted = "true"
    kmsKeyId = var.eks_kms_secret_encryption_alias_arn
  }
}

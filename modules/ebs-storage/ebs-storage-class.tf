resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-gp3-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

   parameters = {
    type = var.ebs_volume_type
    encrypted = "true"
    iops = var.ebs_volume_iops
    throughput = var.ebs_volume_throughput
    kms_key_id = var.eks_kms_secret_encryption_key_arn
  }
}

resource "kubernetes_storage_class_v1" "ebs_sc_retain" {
  metadata {
    name = "ebs-gp3-sc-retain"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy = "Retain"
  allow_volume_expansion = true
  
  parameters = {
    type = var.ebs_volume_type
    encrypted = "true"
    iops = var.ebs_volume_iops
    throughput = var.ebs_volume_throughput
    kms_key_id = var.eks_kms_secret_encryption_key_arn
  }

}

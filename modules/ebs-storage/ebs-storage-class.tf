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
  }
}

resource "kubernetes_storage_class_v1" "ebs_sc_retain" {
  metadata {
    name = "ebs-gp3-sc-retain"
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
  }

}

resource "kubernetes_storage_class_v1" "efs_sc" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks_efs.id
    directoryPerms   = "700"
  }
}

resource "aws_efs_file_system" "eks_efs" {
  creation_token = "${var.k8s_cluster_name}-efs"
  encrypted      = true
  
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "${var.k8s_cluster_name}-efs"
  }
}

resource "aws_efs_mount_target" "eks_efs_mount" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.eks_efs.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group" "efs_sg" {
  name        = "${var.k8s_cluster_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from EKS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.k8s_cluster_name}-efs-sg"
  }
}

 
# AWS EKS node group SPOT

resource "aws_eks_node_group" "demo_eks_nodegroup_spot" {
  count = var.required_spot_instances ? 1 : 0

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-nodes-group-spot",0,64)  
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type = "SPOT"
  instance_types  = var.spot_instance_types

  # Force EKS-optimized AMI usage
  #ami_type = var.eks_optimized_ami_type # "AL2_x86_64"  # Amazon Linux 2

  launch_template {
    id      = aws_launch_template.eks_worker_nodes_spot.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.base_scaling_config_spot.desired_size
    max_size     = var.base_scaling_config_spot.max_size
    min_size     = var.base_scaling_config_spot.min_size
  }

  update_config {
    #max_unavailable = 1
    max_unavailable_percentage = 50
  }
  lifecycle {
    create_before_destroy = true
  }

  labels = {
    node = substr("${var.cluster_name}-${var.environment}-spot-worker-node",0,64) 
    lifecycle = "spot"
    type      = "spot-node"
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "aws:eks:cluster-name" = "${aws_eks_cluster.demo_eks_cluster.name}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "instance_capacity_type" = "SPOT"
    "node-role.kubernetes.io/worker" = ""
    "monitoring" = "enabled"  # Custom label
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role.eks_worker_nodes_role,
    aws_eks_cluster.demo_eks_cluster
  ]
}



resource "aws_launch_template" "eks_worker_nodes_spot" {
  name_prefix   = "${aws_eks_cluster.demo_eks_cluster.name}-eks-node-template-spot-"
  #image_id      = data.aws_ssm_parameter.eks_optimized_ami.value

  #instance_type = "t2.medium"  # default/fallback

    # Conditionally apply user_data
  user_data = var.increase_spot_pod_density ? data.template_cloudinit_config.eks_user_data_spot.rendered : null
 
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_volume_size_in_gb
      volume_type = var.ebs_volume_type 
      encrypted   = true
      kms_key_id  = var.eks_kms_secret_encryption_key_arn
      delete_on_termination = true  # Recommended for EKS nodes
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node-spot"
      Name = "${aws_eks_cluster.demo_eks_cluster.name}-worker-node"
    }
  }
  
}

 

 data "template_cloudinit_config" "eks_user_data_spot" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      set -ex
      /etc/eks/bootstrap.sh ${var.cluster_name} \
        --use-max-pods false
    EOF
  }
}

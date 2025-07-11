
 
# AWS EKS node group SPOT

resource "aws_eks_node_group" "demo_eks_nodegroup_spot" {
  count = var.required_spot_instances ? 1 : 0

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-${var.environment}-workernodes-group-spot",0,64)  
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type = "SPOT"
  instance_types  = var.spot_instance_types

  launch_template {
    id      = aws_launch_template.eks_worker_nodes_spot.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.scaling_config_spot.desired_size
    max_size     = var.scaling_config_spot.max_size
    min_size     = var.scaling_config_spot.min_size
  }

  update_config {
    #max_unavailable = 1
    max_unavailable_percentage = 50
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
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role.eks_worker_nodes_role,
    aws_eks_cluster.demo_eks_cluster,
    aws_launch_template.eks_worker_nodes_spot

  ]
}



resource "aws_launch_template" "eks_worker_nodes_spot" {
  name_prefix   = "eks-node-template-spot"
 # image_id      = data.aws_ami.eks_worker_ami.id

  #instance_type = "t2.medium"  # default/fallback
 
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_volume_size_in_gb
      volume_type = var.ebs_volume_type 
      encrypted   = true
      kms_key_id  = var.eks_kms_secret_encryption_key_arn
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

 
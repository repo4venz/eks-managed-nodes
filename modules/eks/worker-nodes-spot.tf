
 
# AWS EKS node group SPOT

resource "aws_eks_node_group" "demo_eks_nodegroup_spot" {
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
    desired_size = 3
    max_size     = 6
    min_size     = 1
  }

  update_config {
    #max_unavailable = 1
    max_unavailable_percentage = 50
  }

  labels = {
    node = substr("${var.cluster_name}-${var.environment}",0,64)  
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "aws:eks:cluster-name" = "${aws_eks_cluster.demo_eks_cluster.name}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
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
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      kms_key_id  = var.eks_kms_secret_encryption_key_arn
    }
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node-spot"
      Name = "${aws_eks_cluster.demo_eks_cluster.name}-worker-node"
    }
  }
  
}

 

 
# AWS EKS node group ON_DEMAND
# The node groupd will work with AWS VPC CNI only

resource "aws_eks_node_group" "demo_eks_nodegroup_spot_llm" {
   count = var.required_gpu_spot_instances ? 1 : 0

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-nodegrp-spot-llm-gpu" ,0,64)
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn
  instance_types =  var.gpu_spot_instance_types #["g5.2xlarge"] # GPU instance types  #"${var.llm_instance_types[0]}" # GPU instance types


  ami_type =  var.eks_optimized_gpu_ami_type # Amazon Linux 2023 with GPU support
  subnet_ids =  var.private_subnets
  capacity_type = "SPOT"
  #ami_type = "AL2023_x86_64_NVIDIA" #"AL2_x86_64_GPU" # Amazon Linux 2 with GPU support
  
 
  launch_template {
    id      = aws_launch_template.eks_worker_nodes_spot_nvidia_gpu.id
    version = "$Latest"
  }
 

  # Optional: Add taints to ensure only GPU workloads run on these nodes
  taint {
    key    = "nvidia.com/gpu"
    value  = "true"
    effect = "NO_SCHEDULE"
  } 

  scaling_config {
    desired_size =  var.base_scaling_config_spot.desired_size
    max_size     =  var.base_scaling_config_spot.max_size
    min_size     =  var.base_scaling_config_spot.min_size
  }

  update_config {
    max_unavailable_percentage = 50
  }
  lifecycle {
    create_before_destroy = true
  }
  labels = {
    node = "${var.cluster_name}-${var.environment}-spot-worker-node-llm" 
    lifecycle = "spot"
    type      = "spot-node-llm"
    nodegroup = "llm-gpu"
    accelerator = "nvidia"
    instance-type = "gpu"
    "nvidia.com/gpu" = "true"  # Optional label for node selection
    "gpu"            = "enabled"
    "nvidia.com/gpu.present" = "true"
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "aws:eks:cluster-name" = "${aws_eks_cluster.demo_eks_cluster.name}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "instance_capacity_type" = "SPOT"
    "node-role.kubernetes.io/worker" = ""
    "monitoring" = "enabled"  # Custom label
    "project" = "llm"  # Custom label
    "eks.amazonaws.com/nodegroup" = "nvidia-gpu-llm" # Custom label
    "eks.amazonaws.com/nodegroup-type" = "gpu-llm" # Custom label
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

 
 
 # Launch Template for NVIDIA GPU EKS Worker Nodes

 resource "aws_launch_template" "eks_worker_nodes_spot_nvidia_gpu" {
  name_prefix   = "${aws_eks_cluster.demo_eks_cluster.name}-llm-gpu-spot-" 
 
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_volume_size_in_gb_for_gpu
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
      NodeType = "eks-worker-node-gpu-spot"
      Name = "${aws_eks_cluster.demo_eks_cluster.name}-worker-node-nvidia-gpu"
    }
  }
  
}

 
 
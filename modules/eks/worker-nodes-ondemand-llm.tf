
 
# AWS EKS node group ON_DEMAND
# The node groupd will work with AWS VPC CNI only

resource "aws_eks_node_group" "demo_eks_nodegroup_ondemand_llm" {
   count = var.required_llm_instances ? 1 : 0

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-${var.environment}-nodegrp-ondemand-llm-gpu" ,0,64)
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets
  capacity_type = "ON_DEMAND"
  #ami_type = "AL2023_x86_64_NVIDIA" #"AL2_x86_64_GPU" # Amazon Linux 2 with GPU support

  launch_template {
    id      = aws_launch_template.eks_worker_nodes_ondemand_llm.id
    version = "$Latest"
  }

  scaling_config {
    desired_size =  var.base_scaling_config_ondemand.desired_size
    max_size     =  var.base_scaling_config_ondemand.max_size
    min_size     =  var.base_scaling_config_ondemand.min_size
  }

  update_config {
    max_unavailable_percentage = 50
  }
  lifecycle {
    create_before_destroy = true
  }
  labels = {
    node = "${var.cluster_name}-${var.environment}-ondemand-worker-node-llm" 
    lifecycle = "ondemand"
    type      = "ondemand-node-llm"
    nodegroup = "llm-gpu"
    "accelerator" = "nvidia"
    "instance-type" = "gpu"
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "aws:eks:cluster-name" = "${aws_eks_cluster.demo_eks_cluster.name}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "instance_capacity_type" = "ON_DEMAND"
    "node-role.kubernetes.io/worker" = ""
    "monitoring" = "enabled"  # Custom label
    "project" = "llm"  # Custom label
    "eks.amazonaws.com/nodegroup" = "llm-ondemand-gpu" # Custom label
    "eks.amazonaws.com/nodegroup-type" = "ondemand-llm" # Custom label
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

 
 

 # Launch Template for High-Pod-Density Nodes
resource "aws_launch_template" "eks_worker_nodes_ondemand_llm" { 
  name_prefix = "${aws_eks_cluster.demo_eks_cluster.name}-llm-gpu-ondemand-" 
  instance_type = var.llm_instance_types[0]
  image_id = data.aws_ssm_parameter.eks_optimized_nvidia_gpu_ami.value
    
  block_device_mappings {
    #device_name = var.use_bottlerocket ? "/dev/xvda" : "/dev/xvdb"
    device_name = "/dev/xvda"
    ebs {
      volume_size = 100 # Size in GB, adjust as needed
      volume_type = var.ebs_volume_type 
      encrypted   = true
      kms_key_id  = var.eks_kms_secret_encryption_key_arn
      delete_on_termination = true  # Recommended for EKS nodes
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
 
   # Required for EKS node groups
  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node-ondemand-llm"
      Name = substr("${aws_eks_cluster.demo_eks_cluster.name}-worker-node-llm",0,64)
      instance_type = "${var.llm_instance_types[0]}" # Use the first instance type from the list 
    }
  }
   
}

 
 
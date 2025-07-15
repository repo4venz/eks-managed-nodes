
 
# AWS EKS node group ON_DEMAND
# The node groupd will work with AWS VPC CNI only

resource "aws_eks_node_group" "demo_eks_nodegroup_ondemand_high_pod" {

  for_each = var.ondemand_node_groups_customised_config

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-${var.environment}-${replace(each.key, ".", "")}-nodegrp-ondemand-high-pods",0,64)
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type = "ON_DEMAND"
  #instance_types  = var.ondemand_instance_types[each.key]  # not needed as mentioned in launch template
 
  # Force EKS-optimized AMI usage
  #ami_type = var.eks_optimized_ami_type # "AL2_x86_64"  # Amazon Linux 2

  launch_template {
    id      = aws_launch_template.eks_worker_nodes_ondemand_high_pod[each.key].id
    version = "$Latest"
  }

  scaling_config {
    desired_size =  each.value.desired_size  #var.base_scaling_config_ondemand.desired_size
    max_size     =  each.value.max_size    #var.base_scaling_config_ondemand.max_size
    min_size     =  each.value.min_size  #var.base_scaling_config_ondemand.min_size
  }

  update_config {
    #max_unavailable = 1
    max_unavailable_percentage = 50
  }
  lifecycle {
    create_before_destroy = true
  }

  labels = {
    node = "${var.cluster_name}-${var.environment}-ondemand-worker-node-high-pods" 
    lifecycle = "ondemand"
    type      = "ondemand-node-high-pods"
    nodegroup = each.key
  }

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "aws:eks:cluster-name" = "${aws_eks_cluster.demo_eks_cluster.name}"
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.demo_eks_cluster.name}" = "owned"
    "instance_capacity_type" = "ondemand"
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

 
 

 # Launch Template for High-Pod-Density Nodes
resource "aws_launch_template" "eks_worker_nodes_ondemand_high_pod" {
 
  for_each = var.ondemand_node_groups_customised_config

  name_prefix = "${aws_eks_cluster.demo_eks_cluster.name}-high-pod-${replace(each.key , ".", "")}-" 

  instance_type = each.key
 # image_id      = data.aws_ssm_parameter.eks_optimized_ami.value
  user_data = data.template_cloudinit_config.eks_user_data_ondemand_high_pods[each.key].rendered
    
  block_device_mappings {
    #device_name = var.use_bottlerocket ? "/dev/xvda" : "/dev/xvdb"
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
 
   # Required for EKS node groups
  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node-ondemand-high-pods"
      Name = substr("${aws_eks_cluster.demo_eks_cluster.name}-worker-node-${each.key }",0,64)
      instance_type = "${each.key}"  
    }
  }
 
}

 


data "template_cloudinit_config" "eks_user_data_ondemand_high_pods" {
  for_each = var.ondemand_node_groups_customised_config
  gzip          = false
  base64_encode = true

  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      set -ex
      echo "### DEBUG ###"
      ls -la /etc/eks
      cat /etc/eks/bootstrap.sh
      whoami
      /etc/eks/bootstrap.sh ${var.cluster_name} \
        --use-max-pods false \
        --kubelet-extra-args '--max-pods=${each.value.max_pods}'
    EOF
  }
}

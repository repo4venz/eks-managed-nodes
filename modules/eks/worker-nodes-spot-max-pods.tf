
 
# AWS EKS node group SPOT
# The node groupd will work with AWS VPC CNI only

resource "aws_eks_node_group" "demo_eks_nodegroup_spot_high_pod" {
   #for_each = var.required_spot_instances_max_pods ? toset(var.spot_instance_types) : null
  /*
  for_each = var.required_spot_instances_max_pods ? {
    for instance_type in var.spot_node_groups_max_pods : instance_type => instance_type
  } : {} */

   /* for_each = var.required_spot_instances_max_pods ? {
    for instance_type, config in var.spot_node_groups_max_pods : 
    "spot_${replace(instance_type, ".", "_")}" => {
      instance_type = instance_type
      max_pods      = config.max_pods
      desired_size  = config.desired_size
      min_size      = config.min_size
      max_size      = config.max_size
    }
  } : {}
*/

  #If var.create_instances is true, use var.instance_map (create instances)
  #If var.create_instances is false, use an empty map {} (don't create any instances but don't destroy if created)
  #If var.create_instances is false, use another for (don't create any instances and destroy is created)


  for_each = var.spot_node_groups_max_pods

  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = "${var.cluster_name}-${var.environment}-${replace(each.key, ".", "")}-nodes-group-spot-high-pods" 
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type = "SPOT"
  #instance_types  = var.spot_instance_types[each.key]  # not needed as mentioned in launch template

  launch_template {
    id      = aws_launch_template.eks_worker_nodes_spot_high_pod[each.key].id
    version = "$Latest"
  }

  scaling_config {
    desired_size =  each.value.desired_size  #var.scaling_config_spot.desired_size
    max_size     =  each.value.max_size    #var.scaling_config_spot.max_size
    min_size     =  each.value.min_size  #var.scaling_config_spot.min_size
  }

  update_config {
    #max_unavailable = 1
    max_unavailable_percentage = 50
  }

  labels = {
    node = "${var.cluster_name}-${var.environment}-spot-worker-node-high-pods" 
    lifecycle = "spot"
    type      = "spot-node-high-pods"
    nodegroup = each.key
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
    aws_eks_cluster.demo_eks_cluster,
    aws_launch_template.eks_worker_nodes_spot_high_pod

  ]
}

/*
locals {
  # Pre-calculated max pods based on AWS ENI limits
  max_pods_map = {
    "t3.large"    = 35
    "t3.xlarge"   = 58
    "t3.2xlarge"  = 58
    "m5.large"    = 29
    "m5.xlarge"   = 58
    "m5.2xlarge"  = 58
    "m5.4xlarge"  = 234  # With prefix delegation
    "c5.4xlarge"  = 234
    "r5.8xlarge"  = 234
  }
}
*/

 

 # Launch Template for High-Pod-Density Nodes
resource "aws_launch_template" "eks_worker_nodes_spot_high_pod" {
   #for_each = var.required_spot_instances_max_pods ? toset(var.spot_instance_types) : null
  /*
  for_each = var.required_spot_instances_max_pods ? {
    for instance_type in var.spot_node_groups_max_pods : instance_type => instance_type
  } : {} */

   /* for_each = var.required_spot_instances_max_pods ? {
    for instance_type, config in var.spot_node_groups_max_pods : 
    "spot_${replace(instance_type, ".", "_")}" => {
      instance_type = instance_type
      max_pods      = config.max_pods
      desired_size  = config.desired_size
      min_size      = config.min_size
      max_size      = config.max_size
    }
  } : {}
*/

  #If var.create_instances is true, use var.instance_map (create instances)
  #If var.create_instances is false, use an empty map {} (don't create any instances but don't destroy if created)
  #If var.create_instances is false, use another for (don't create any instances and destroy is created)


  for_each = var.spot_node_groups_max_pods

  name_prefix = "${aws_eks_cluster.demo_eks_cluster.name}-high-pod-${replace(each.key , ".", "")}-" 

  instance_type = each.key
  
   /*
  user_data = base64encode(templatefile("${path.module}/worker-node-userdata.tftpl", {
    cluster_name     = var.cluster_name
    max_pods         = each.value.max_pods    #local.max_pods_map[each.value]
   # bottlerocket     = var.use_bottlerocket
    custom_kubelet_args = "--node-labels=group=${each.key}-spot"  #var.custom_kubelet_args
  })) 
  */

   # Correct user data encoding
user_data = base64encode(<<-EOF
      MIME-Version: 1.0
      Content-Type: multipart/mixed; boundary="==BOUNDARY=="

                --==BOUNDARY==
      Content-Type: text/x-shellscript; charset="us-ascii"

      #!/bin/bash
      set -ex
      /etc/eks/bootstrap.sh ${var.cluster_name} \
      --use-max-pods false \
      --kubelet-extra-args "--max-pods=${each.value.max_pods}"
                --==BOUNDARY==--
      EOF
    )
    
  block_device_mappings {
    #device_name = var.use_bottlerocket ? "/dev/xvda" : "/dev/xvdb"
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
 
   # Required for EKS node groups
  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node-spot-high-pods"
      Name = substr("${aws_eks_cluster.demo_eks_cluster.name}-worker-node-${each.key }",0,64)
      instance_type = "${each.key}"  
    }
  }
}

 



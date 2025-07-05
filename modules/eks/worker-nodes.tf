/* ==========================================
Creating IAM Role for EKS Wroker Nodes EC2
==============================================*/

resource "aws_iam_role" "eks_worker_nodes_role" {
  name = substr("${var.cluster_name}-${var.environment}-workernodes-role",0,64)
  #name = "EKSWorkerNodesRole"
  description = " IAM role for the EKS worker nodes."
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [       
           "ec2.amazonaws.com"
          ]
      },
      "Action":  [ 
          "sts:AssumeRole",
          "sts:TagSession"
          ]
    }
  ]
}
POLICY
}


# IAM policy attachment to nodegroup

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.eks_worker_nodes_role.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.eks_worker_nodes_role.name
 }

 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.eks_worker_nodes_role.name
 }
 

 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.eks_worker_nodes_role.name
 }

# Allow worker node-group to access KMS key for EBS volume encryption / decryption of worker nodes
 resource "aws_iam_role_policy_attachment" "eks_kms_usage_nodegroup" {
  policy_arn = aws_iam_policy.EKS_KMS_Usage_Policy.arn
  role       = aws_iam_role.eks_worker_nodes_role.name
}

 
# AWS EKS node group 

resource "aws_eks_node_group" "demo_eks_nodegroup" {
  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-${var.environment}-workernodes-group",0,64)  
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type = "SPOT"

  launch_template {
    id      = aws_launch_template.eks_worker_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 3
    max_size     = 10
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
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role.eks_worker_nodes_role,
    aws_eks_cluster.demo_eks_cluster,
    aws_launch_template.eks_worker_nodes

  ]
}



resource "aws_launch_template" "eks_worker_nodes" {
  name_prefix   = "eks-node-template-"
 # image_id      = data.aws_ami.eks_worker_ami.id

  instance_type = "t2.medium"
 
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      kms_key_id  = var.eks_kms_secret_encryption_key_arn
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.eks_node_instance_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      NodeType = "eks-worker-node"
    }
  }
  depends_on = [
    aws_iam_instance_profile.eks_node_instance_profile
  ]
}


resource "aws_iam_instance_profile" "eks_node_instance_profile" {
  name = "eks-node-instance-profile"
  role = aws_iam_role.eks_worker_nodes_role.arn
}


 
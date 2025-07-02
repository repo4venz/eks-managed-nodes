/* ==========================================
Creating IAM Role for EKS Wroker Nodes EC2
==============================================*/

resource "aws_iam_role" "eks_worker_nodes_role" {
  name = substr("${var.cluster_name}-${var.environment}-workernodes-role",0,64)
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
 
# AWS EKS node group 

resource "aws_eks_node_group" "demo_eks_nodegroup" {
  cluster_name    = aws_eks_cluster.demo_eks_cluster.name
  node_group_name = substr("${var.cluster_name}-${var.environment}-workernodes-group",0,64)  
  node_role_arn   = aws_iam_role.eks_worker_nodes_role.arn

  subnet_ids =  var.private_subnets

  capacity_type  = "SPOT"
  instance_types = ["t2.medium"]

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

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.EC2InstanceProfileForImageBuilderECRContainerBuilds,
    aws_iam_role.eks_worker_nodes_role

  ]
}

 
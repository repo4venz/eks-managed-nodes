/* ==========================================
Creating IAM Role for EKS Wroker Nodes EC2
==============================================*/

resource "aws_iam_role" "eks_worker_nodes_role" {
  name = substr("${var.cluster_name}-workernodes-role",0,64)
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

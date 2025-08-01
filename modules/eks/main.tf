

# Creating CloudWatch Log Group for EKS Cluster
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
  kms_key_id = var.eks_kms_cloudwatch_logs_encryption_alias_arn

  tags = {
    Name        = "${var.cluster_name}-${var.environment}-eks-cloudwatch-log-group"
  }
}



/* ==================================================
Creating IAM Policies for EKS Cluster  
=====================================================*/

# AWS IAM Policy for CloudWatch. Required for EKS to generrate Control Plane logs.
resource "aws_iam_policy" "AmazonEKSClusterCloudWatchMetricsPolicy" {
  name   = substr("${var.cluster_name}-AmazonEKSClusterCloudWatchMetricsPolicy",0,64)
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}


/* ==================================
Creating IAM Role for EKS Cluster 
=====================================*/

resource "aws_iam_role" "eks_cluster_role" {
  name = substr("${var.cluster_name}-cluster-role",0,64)
  description = "Allow cluster to manage node groups, managed nodes and cloudwatch logs"
  force_detach_policies = true
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [       
           "eks.amazonaws.com",
           "eks-fargate-pods.amazonaws.com"
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

## Attaching all the policies with the EKS Role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatchMetricsPolicy" {
  policy_arn = aws_iam_policy.AmazonEKSClusterCloudWatchMetricsPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks_cluster_role.name
}
 
resource "aws_iam_role_policy_attachment" "eks_kms_usage" {
  policy_arn = aws_iam_policy.EKS_KMS_Usage_Policy.arn
  role       = aws_iam_role.eks_cluster_role.name
}





/* =====================
Creating EKS Cluster 
========================*/
resource "aws_eks_cluster" "demo_eks_cluster" {
  name     = var.cluster_name
   
  role_arn = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  version  = var.cluster_version
  
   vpc_config {
    subnet_ids =  concat(var.public_subnets, var.private_subnets)
  }

   access_config {
      authentication_mode = "API_AND_CONFIG_MAP"
   } 

   encryption_config {
	    provider {
	      key_arn = var.eks_kms_secret_encryption_alias_arn
	    }	
	    resources = ["secrets"]
	  }

   
   timeouts {
     delete    =  "30m"
   }
  
  depends_on = [
    aws_iam_role.eks_cluster_role,
    aws_cloudwatch_log_group.cloudwatch_log_group,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSCloudWatchMetricsPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS,
    aws_iam_role_policy_attachment.eks_kms_usage
  ]
}





 
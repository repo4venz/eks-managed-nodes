 

## 2. Create IAM Policy for Pod Access
resource "aws_iam_policy" "pod_access_policy_for_nvidia" {
  name        = substr("${var.k8s_cluster_name}-eks-pod-access-policy-nvidia-device",0,64)  
  description = "Policy for EKS pod access to AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "eks:*",
            "ec2:*", 
            "sts:AssumeRole"
             ]
        Resource = ["*"]
      }
    ]
  })
}

## 3. Create IAM Role for Pod Identity
resource "aws_iam_role" "pod_identity_role_nvidia" {
  name = "eks-pod-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}",
            "eks:cluster-name" : "${var.k8s_cluster_name}"
          }
        }
      }
    ]
  })
}
 

resource "aws_iam_role_policy_attachment" "pod_policy_nvidia_attach" {
  role       = aws_iam_role.pod_identity_role_nvidia.name
  policy_arn = aws_iam_policy.pod_access_policy_for_nvidia.arn
}
           


## 5. Create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "nvidia_device_plugin_association" {
  cluster_name    = var.k8s_cluster_name
  namespace       = var.namespace
  service_account = var.nvidia_service_account_name
  role_arn        = aws_iam_role.pod_identity_role_nvidia.arn

    depends_on = [
        aws_iam_role_policy_attachment.pod_policy_nvidia_attach
    ]
}
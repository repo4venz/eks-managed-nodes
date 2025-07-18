 

## 2. Create IAM Policy for Pod Access
resource "aws_iam_policy" "pod_access_policy_for_mcp_server" {
  name        = substr("${var.k8s_cluster_name}-eks-pod-access-policy_mcp_server",0,64)  
  description = "Policy for EKS pod access to AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "eks:*",
            "cloudformation:*",
            "iam:*",
            "organizations:Describe*",
            "organizations:List*",
            "ec2:*", 
            "sts:AssumeRole"
             ]
        Resource = ["*"]
      }
    ]
  })
}

## 3. Create IAM Role for Pod Identity
resource "aws_iam_role" "pod_identity_role_mcp_server" {
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

## 4. Attach Policy to Role

resource "aws_iam_role_policy_attachment" "pod_policy_multiple_attachments" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.pod_identity_role_mcp_server.name
  policy_arn = each.value
}

 

## 5. Create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "mcp_server" {
  cluster_name    = var.k8s_cluster_name
  namespace       = "agentic-ai"
  service_account = "mcp-server-sa"
  role_arn        = aws_iam_role.pod_identity_role_mcp_server.arn

    depends_on = [
        aws_iam_role_policy_attachment.pod_policy_multiple_attachments
    ]
}

/*
# IAM Role for k8sgpt Service Account (IRSA)
resource "aws_iam_role" "k8sgpt_role" {
  name  = "${var.k8s_cluster_name}-k8sgpt-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.oidc.arn
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8sgpt_namespace}:${var.k8sgpt_service_account_name}"
        }
      }
    }]
  })
  
}



## 2. Create IAM Policy for Pod Access
resource "aws_iam_policy" "pod_access_policy_for_k8sgpt" {
  name        = substr("${var.k8s_cluster_name}-eks-pod-access-policy-k8sgpt",0,64)  
  description = "Policy for EKS pod access to AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "bedrock:InvokeModel",
            "bedrock:InvokeModelWithResponseStream"
             ]
        Resource = [
          "arn:aws:bedrock:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0",
          "arn:aws:bedrock:eu-central-1:${data.aws_caller_identity.current.account_id}:foundation-model/*",

        ]
      }
    ]
  })
}

 
resource "aws_iam_role_policy_attachment" "kubecost_custom" {
  role       = aws_iam_role.kubecost.name
  policy_arn = aws_iam_policy.kubecost_policy.arn
}
 

*/



## 2. Create IAM Policy for Pod Access
resource "aws_iam_policy" "pod_access_policy_for_k8sgpt" {
  name        = substr("${var.k8s_cluster_name}-eks-pod-access-policy-k8sgpt",0,64)  
  description = "Policy for EKS pod access to AWS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "bedrock:InvokeModel",
            "bedrock:InvokeModelWithResponseStream"
             ]
                Resource = [
          "arn:aws:bedrock:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0",
          "arn:aws:bedrock:eu-central-1:${data.aws_caller_identity.current.account_id}:foundation-model/*"
        ]
        }
    ]
  })
}

## 3. Create IAM Role for Pod Identity
resource "aws_iam_role" "pod_identity_role_k8sgpt" {
  name =  substr("${var.k8s_cluster_name}-eks-pod-identity-role-k8sgpt",0,64)  

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
 

resource "aws_iam_role_policy_attachment" "pod_policy_k8sgpt_attach" {
  role       = aws_iam_role.pod_identity_role_k8sgpt.name
  policy_arn = aws_iam_policy.pod_access_policy_for_k8sgpt.arn
}
           


## 5. Create EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "k8sgpt_association" {
  cluster_name    = var.k8s_cluster_name
  namespace       = var.k8sgpt_namespace
  service_account = var.k8sgpt_service_account_name
  role_arn        = aws_iam_role.pod_identity_role_k8sgpt.arn

    depends_on = [
        helm_release.k8sgpt
    ]
}
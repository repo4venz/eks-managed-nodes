# modules/k8sGPT/main.tf
 
/*
# IAM Role for k8sGPT Service Account (IRSA)
resource "aws_iam_role" "k8sgpt_irsa_role" {
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



resource "aws_iam_policy" "k8sgpt_policy" {
  name   = substr("${var.k8s_cluster_name}-k8sgpt-policy",0,64)
  description = "IAM policy for k8sGPT to access Bedrock AWS resources"
  policy = jsonencode( {
	"Statement": [
		{
			"Action": [
				"bedrock:InvokeModel",
				"bedrock:InvokeModelWithResponseStream"
			],
			"Effect": "Allow",
			"Resource": [
				"arn:aws:bedrock:eu-central-1::foundation-model/anthropic.claude-3-5-sonnet-20240620-v1:0"
			]
		}
	],
	"Version": "2012-10-17"
  })
}

 

resource "aws_iam_role_policy_attachment" "k8sgpt_policy_attach" {
  role       = aws_iam_role.k8sgpt_irsa_role.name
  policy_arn = aws_iam_policy.k8sgpt_policy.arn
}
*/
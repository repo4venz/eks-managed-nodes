resource "aws_iam_role" "kube_cost_role" {
  name  = substr("${var.k8s_cluster_name}-kube-cost-irsa-role",0,64)
  description = "IAM Role for Kube-Cost"
  assume_role_policy = data.aws_iam_policy_document.kube_cost_assume.json
}

resource "aws_iam_policy" "kube_cost_policy" {
  name   = substr("${var.k8s_cluster_name}-kube-cost-policy",0,64)
  description = "IAM policy for Kube-Cost"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
                    "ce:GetCostAndUsage",
                    "ce:GetDimensionValues",
                    "ce:GetReservationUtilization",
                    "ce:GetSavingsPlansUtilization",
                    "ce:GetTags",
                    "ce:GetRightsizingRecommendation",
                    "ec2:Describe*",
                    "pricing:GetProducts",
                    "s3:Get*",
                    "s3:List*",
                    "organizations:Describe*",
                    "organizations:List*",
                    "cur:DescribeReportDefinitions"
			],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kubecost_attach" {
  role       = aws_iam_role.kube_cost_role.name
  policy_arn = aws_iam_policy.kube_cost_policy.arn
}


resource "aws_iam_role_policy_attachment" "kubecost_irsa" {
  for_each   = toset(var.kubecost_iam_policies)
  role       = aws_iam_role.kubecost_irsa.name
  policy_arn = each.value
}

 

locals {
  kubecost_values = yamlencode({
    global = {
      grafana = { enabled = true  }
      prometheus = {
        kubeStateMetrics = { enabled = true }
        nodeExporter     = { enabled = true }
        server = {
          persistentVolume = {
            enabled        = true
            storageClass   = "ebs-csi-default-sc" #"gp2"
            size           = "10Gi"
          }
        }
        serviceAccounts = {
          server = {
            create = true
            name   = "kubecost-cost-analyzer"
            annotations = {
              "eks.amazonaws.com/role-arn" = aws_iam_role.kube_cost_role.arn
            }
          }
        }
      }
    }

      kubecostFrontend = {
        ingress = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress.class"                    = "nginx"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
            "cert-manager.io/cluster-issuer"                 = "letsencrypt-${var.environment}"
            "external-dns.alpha.kubernetes.io/hostname"      = var.kubecost_hostname
          }
          hosts = [{
            host = var.kubecost_hostname
            paths = [{
              path     = "/"
              pathType = "Prefix"
            }]
          }]
          tls = [{
            hosts      = [var.kubecost_hostname]
            secretName = "kubecost-tls"
          }]
        }
      }
  })
}
 


 
  

resource "helm_release" "kubecost" {
  name             = "kubecost"
  namespace        = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer"
  chart            = "cost-analyzer"
  version          = var.kubecost_chart_version # Latest as of July 2025
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 900
  wait             = true

 values = [ local.kubecost_values  ]

    depends_on = [
    aws_iam_role.kube_cost_role,
    aws_iam_role_policy_attachment.kubecost_attach
  ]
}


 
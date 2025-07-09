# modules/kubecost/main.tf
 

# IAM Role for Kubecost Service Account (IRSA)
resource "aws_iam_role" "kubecost" {
  name               = "${var.k8s_cluster_name}-kubecost-irsa"
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
          "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })
  tags = var.tags
}



resource "aws_iam_policy" "kubecost_policy" {
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
                    "ce:Get*",
                    "ce:Describe*",
                    "ce:List*",
                    "ec2:Describe*",
                    "pricing:GetProducts",
                    "s3:Get*",
                    "s3:List*",
                    "organizations:Describe*",
                    "organizations:List*",
                    "cur:DescribeReportDefinitions",
                    "ce:UntagResource"
			],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kubecost" {
  for_each   = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSResourceGroupsReadOnlyAccess",
     aws_iam_policy.kube_cost_policy.arn,
  ])
  role       = aws_iam_role.kubecost.name
  policy_arn = each.value
}
 

# Kubecost Helm Release
resource "helm_release" "kubecost" {
  name       = "kubecost"
  repository = "https://kubecost.github.io/cost-analyzer/"
  chart      = "cost-analyzer"
  version    = var.kubecost_chart_version
  namespace  = var.namespace

  set {
    name  = "global.clusterName"
    value = var.k8s_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kubecost.arn
  }

  set {
    name  = "kubecostProductConfigs.clusterName"
    value = var.k8s_cluster_name
  }

  set {
    name  = "kubecostProductConfigs.awsAthenaProjectID"
    value = data.aws_caller_identity.current.account_id
  }

  set {
    name  = "kubecostProductConfigs.awsRegion"
    value = data.aws_region.current.id
  }

  # Persistent Volume Configuration
  set {
    name  = "prometheus.server.persistentVolume.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.server.persistentVolume.storageClass"
    value = var.storage_class
  }

  set {
    name  = "prometheus.server.persistentVolume.size"
    value = var.storage_size
  }

  set {
    name  = "prometheus.server.retention"
    value = var.prometheus_retention
  }

  depends_on = [aws_iam_role_policy_attachment.kubecost]
}

# Ingress with TLS
resource "kubernetes_ingress_v1" "kubecost" {
  metadata {
    name        = "kubecost-ingress"
    namespace   = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                  = "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "cert-manager.io/cluster-issuer"               = "letsencrypt-${var.environment}"
      "external-dns.alpha.kubernetes.io/hostname"    = var.ingress_host
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "kubecost-cost-analyzer"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = [var.ingress_host]
      secret_name = "kubecost-tls"
    }
  }

  depends_on = [
    helm_release.kubecost 
  ]
}
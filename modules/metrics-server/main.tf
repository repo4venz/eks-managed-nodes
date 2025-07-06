 

resource "aws_iam_role" "metrics_server" {
  name = substr("${var.k8s_cluster_name}-metrics-server-irsa-role",0,64)

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.this.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(data.aws_iam_openid_connect_provider.this.url, "https://", "")}:sub" = "system:serviceaccount:${var.k8s_namespace}:metrics-server"
        }
      }
    }]
  })
}

resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  version          = var.metrics_server_chart_version # latest as of July 2025
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "metrics-server"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.metrics_server.arn
        }
      }
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS"
      ]
    })
  ]

  depends_on = [aws_iam_role.metrics_server]
}


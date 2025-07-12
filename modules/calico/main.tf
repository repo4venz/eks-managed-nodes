resource "aws_iam_role" "calico_role" {
  name = substr("${var.k8s_cluster_name}-calico-irsa-role",0,64)
  description = "IAM Role for Calico for EKS networking"
  assume_role_policy = data.aws_iam_policy_document.calico_assume_role_policy.json
}


resource "aws_iam_policy" "calico_policy" {
  name   = substr("${var.k8s_cluster_name}-calico-policy",0,64)
  description = "IAM policy for Calico for for EKS networking"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags"
			],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "calico_attach" {
  role       = aws_iam_role.calico_role.name
  policy_arn = aws_iam_policy.calico_policy.arn
}

 

# Calico Helm Release with yamlencode for values
resource "helm_release" "calico" {
  name       = "calico"
  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "tigera-operator"
  version    = var.calico_chart_version
  namespace  = var.namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout    = 900

  values = [
    yamlencode({
      installation = {
        kubernetesProvider = "EKS"
        awsNodeManaged    = true  # Integrate with AWS VPC CNI
        cni = {
          type = "AmazonVPC"
        }
        typha = {
          enabled = true
          serviceAccount = {
            annotations = {
              "eks.amazonaws.com/role-arn" = aws_iam_role.calico_role.arn
            }
          }
        }
        nodeUpdateStrategy = {
          rollingUpdate = {
            maxUnavailable = 1
          }
          type = "RollingUpdate"
        }
      }
      customResources = {
        enable = true
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.calico_attach
  ]
}

/*
# NetworkPolicy Custom Resources
resource "kubernetes_manifest" "calico_global_network_policy" {
  manifest = yamlencode({
    apiVersion = "projectcalico.org/v3"
    kind       = "GlobalNetworkPolicy"
    metadata = {
      name = "default-deny"
    }
    spec = {
      selector = "all()"
      types    = ["Ingress", "Egress"]
      # Deny all traffic by default (override with specific policies)
      ingress = []
      egress  = []
    }
  })

  depends_on = [helm_release.calico]
}
*/

/*

apiVersion: "projectcalico.org/v3"  # Calico-specific CRD
kind: "GlobalNetworkPolicy"         # Applies cluster-wide
metadata:
  name: "default-deny"             # Policy identifier
spec:
  selector: "all()"                # Applies to ALL pods
  types: ["Ingress", "Egress"]     # Controls both inbound/outbound
  ingress: []                      # Empty array = no allowed inbound
  egress: []                       # Empty array = no allowed outbound

  */
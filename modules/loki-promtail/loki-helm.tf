 
# Helm Release for Loki with yamlencoded values
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_chart_version
  namespace  = var.k8s_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300

  values = [
    yamlencode({
      loki = {
        config = {
          storage_config = {
            aws = {
              s3               = "s3://${aws_s3_bucket.loki_storage.id}"
              region           = data.region.current.id
              s3forcepathstyle = true
            }
          }
          schema_config = {
            configs = [{
              from         = "2020-10-24"  # Starting date for this schema
              store        = "boltdb-shipper" # Index storage method
              object_store = "aws"  # Where chunks (log data) are stored
              schema       = "v11"   # Schema version
              index = {
                prefix = "loki_index_" # S3 prefix for index files
                period = "24h"  # How often to rotate index files
              }
            }]
          }
        }
        persistence = {
          enabled = true
          size    = var.loki_storage_size
        }
        serviceAccount = {
          create = true
          annotations = {
            "eks.amazonaws.com/role-arn" = module.loki_irsa.iam_role_arn
          }
        }
        singleBinary = {
          enabled = false
        }
        querier = {
          enabled = true
          replicas = 3
        }
        ingester = {
          enabled = true
          replicas = 3
        }
        serviceMonitor = {
          enabled = true
          additionalLabels = {
            release = "kube-prometheus-stack"
          }
        }
      }
    })
  ]
  depends_on = [ 
    aws_iam_role_policy_attachment.loki_s3_access_attachment,
    aws_s3_bucket.loki_storage   
  ]
}
 
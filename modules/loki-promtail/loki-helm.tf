 
# Helm Release for Loki with yamlencoded values
# Loki will be installed using Helm with the specified configuration.
# Loki is a log aggregation system designed to work with Prometheus.
# Loki stores logs in a time-series database and allows querying logs using PromQL-like queries.
#Loki stores logs in S3, and the configuration includes storage settings, schema, and service account details.
 
/*
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
        # Convert config to YAML string using nested yamlencode
        config = yamlencode({
          storage_config = {
            aws = {
              s3               = "s3://${aws_s3_bucket.loki_storage.id}"
              region           = data.aws_region.current.id
              s3forcepathstyle = true
            }
          }
          schema_config = {
            configs = [{
              from         = "2020-10-24"  # Starting date for this schema
              store        = "boltdb-shipper"   # Index storage method
              object_store = "aws"  # Where chunks (log data) are stored
              schema       = "v11"   # Schema version
              index = {
                prefix = "loki_index_"   # S3 prefix for index files
                period = "24h"    # How often to rotate index files
              }
            }]
          }
        })
        persistence = {
          enabled = true
          size    = var.loki_storage_size
        }
        serviceAccount = {
          create = true
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.loki_role.arn
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
    aws_iam_role_policy_attachment.loki_policy_attachment,
    aws_s3_bucket.loki_storage   
  ]
}

*/

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
          auth_enabled = false
          storage_config = {
            aws = {
              s3               = "s3://${aws_s3_bucket.loki_storage.id}"
              region           = data.aws_region.current.id
              s3forcepathstyle = true
            }
          }
          schema_config = {
            configs = [{
              from         = "2020-10-24"
              store        = "boltdb-shipper"
              object_store = "aws"
              schema       = "v11"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }]
          }
          ingester = {
            lifecycler = {
              ring = {
                kvstore = {
                  store = "inmemory"
                }
                replication_factor = 1
              }
            }
          }
        }
        persistence = {
          enabled = true
          size    = var.loki_storage_size
          storageClassName = "gp2"
        }
        serviceAccount = {
          create = true
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.loki_role.arn
          }
        }
        singleBinary = {
          enabled = false
        }
        write = {
          replicas = 3
        }
        read = {
          replicas = 3
        }
        backend = {
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
    aws_iam_role_policy_attachment.loki_policy_attachment,
    aws_s3_bucket.loki_storage   
  ]
}
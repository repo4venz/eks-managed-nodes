 
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
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  version          = var.loki_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300

  values = [
    yamlencode({
      singleBinary = {
        enabled = false
      }
      serviceAccount = {
        create = true
        name = var.loki_service_account_name
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.loki_role.arn
        }
      }
      serviceMonitor = {
        enabled = true
        additionalLabels = {
          release = "kube-prometheus-stack"
        }
      }
      loki = {
        schemaConfig = {
          configs = [{
            from = "2020-10-24"
            store = "boltdb-shipper"
            object_store = "aws"
            schema = "v11"
            index = {
              prefix = "loki_index_"
              period = "24h"
            }
          }]
        }
        storageConfig = {
          aws = {
            s3 = "s3://${aws_s3_bucket.loki_storage.id}"
            region = data.aws_region.current.name
            s3forcepathstyle = true
          }
          boltdb_shipper = {
            active_index_directory = "/var/loki/index"
            cache_location = "/var/loki/cache"
            cache_ttl = "24h"
            shared_store = "aws"
          }
        }
      }
      ingester = {
        enabled = true
        replicas = 2
        persistence = {
          enabled = true
          size = "10Gi"
          storageClass = "gp3"
        }
      }
      querier = {
        enabled = true
        replicas = 2
      }
      gateway = {
        enabled = true
      }
      ruler = {
        enabled = true
        directories = {
          rules = "/etc/loki/rules"
        }
      }
      compactor = {
        enabled = true
        retention_enabled = true
        retention_delete_delay = "2h"
        retention_delete_worker_count = 150
        working_directory = "/var/loki/compactor"
        shared_store = "aws"
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.loki_policy_attachment,
    aws_s3_bucket.loki_storage
  ]
}

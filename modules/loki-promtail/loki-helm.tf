 
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
/*

resource "helm_release" "loki" {
    name             = "loki"
    repository       = "https://grafana.github.io/helm-charts"
    chart            = "loki"
    #version         = var.loki_chart_version
    namespace        = var.k8s_namespace
    create_namespace = true
    atomic           = true
    cleanup_on_fail  = true
    timeout          = 300

    values = [
        yamlencode({
            deploymentMode = "Distributed"

            singleBinary = {
                enabled = false
            }

            serviceAccount = {
                create      = true
                name        = var.loki_service_account_name
                annotations = {
                    "eks.amazonaws.com/role-arn" = aws_iam_role.loki_role.arn
                }
            }

            serviceMonitor = {
                enabled          = true
                additionalLabels = {
                    release = "kube-prometheus-stack"
                }
            }

            loki = {
                auth_enabled  = false
                commonConfig  = {
                    replication_factor = 1
                }

                schemaConfig = {
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

                storageConfig = {
                    aws = {
                        s3               = "s3://${aws_s3_bucket.loki_storage.id}"
                        region           = data.aws_region.current.id
                        s3forcepathstyle = true
                    }

                    boltdb_shipper = {
                        active_index_directory = "/var/loki/index"
                        cache_location         = "/var/loki/cache"
                        cache_ttl              = "24h"
                        shared_store           = "aws"
                    }
                }

                storage = {
                    bucketNames = {
                        chunks = "${aws_s3_bucket.loki_storage.id}"
                        ruler  = "${aws_s3_bucket.loki_storage.id}"
                        admin  = "${aws_s3_bucket.loki_storage.id}"
                    }
                }
            }

            distributor = {
                replicas       = 2
                maxUnavailable = 1
            }

            ingester = {
                replicas    = 2
                persistence = {
                    enabled      = true
                    size         = "10Gi"
                    storageClass = var.ebs_storage_class_name
                }
            }

            querier = {
                replicas       = 2
                maxUnavailable = 1
            }

            queryFrontend = {
                replicas       = 2
                maxUnavailable = 1
            }

            compactor = {
                enabled                        = true
                retention_enabled              = true
                retention_delete_delay         = "2h"
                retention_delete_worker_count  = 150
                working_directory              = "/var/loki/compactor"
                shared_store                   = "aws"
            }

            ruler = {
                enabled     = true
                replicas    = 1
                directories = {
                    rules = "/etc/loki/rules"
                }
            }

            gateway = {
                enabled = true
            }

            queryScheduler = {
                enabled = true
            }

            frontendWorker = {
                enabled = true
            }

            backend = {
                enabled  = false
                replicas = 0
            }

            read = {
                enabled  = false
                replicas = 0
            }

            write = {
                enabled  = false
                replicas = 0
            }
        })
    ]

    depends_on = [
        aws_iam_role_policy_attachment.loki_policy_attachment,
        aws_s3_bucket.loki_storage
    ]
}
*/

/*
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
        <<-EOT
        deploymentMode: "Distributed"
        
        singleBinary:
          enabled: false
        
        serviceAccount:
          create: true
          name: "${var.loki_service_account_name}"
          annotations:
            eks.amazonaws.com/role-arn: "${aws_iam_role.loki_role.arn}"
        
        serviceMonitor:
          enabled: true
          additionalLabels:
            release: "kube-prometheus-stack"
        
        loki:
          auth_enabled: false
          commonConfig:
            replication_factor: 1
          
          schemaConfig:
            configs:
              - from: "2020-10-24"
                store: "boltdb-shipper"
                object_store: "aws"
                schema: "v11"
                index:
                  prefix: "loki_index_"
                  period: "24h"
          
          storageConfig:
            aws:
              s3: "s3://${aws_s3_bucket.loki_storage.id}"
              region: "${data.aws_region.current.id}"
              s3forcepathstyle: true
            boltdb_shipper:
              active_index_directory: "/var/loki/index"
              cache_location: "/var/loki/cache"
              cache_ttl: "24h"
              shared_store: "aws"
          
          storage:
            bucketNames:
              chunks: "${aws_s3_bucket.loki_storage.id}"
              ruler: "${aws_s3_bucket.loki_storage.id}"
              admin: "${aws_s3_bucket.loki_storage.id}"
        
        distributor:
          replicas: 2
          maxUnavailable: 1
        
        ingester:
          replicas: 2
          persistence:
            enabled: true
            size: "10Gi"
            storageClass: "${var.ebs_storage_class_name}"
        
        querier:
          replicas: 2
          maxUnavailable: 1
        
        queryFrontend:
          replicas: 2
          maxUnavailable: 1
        
        compactor:
          enabled: true
          retention_enabled: true
          retention_delete_delay: "2h"
          retention_delete_worker_count: 150
          working_directory: "/var/loki/compactor"
          shared_store: "aws"
        
        ruler:
          enabled: true
          replicas: 1
          directories:
            rules: "/etc/loki/rules"
        
        gateway:
          enabled: true
        
        queryScheduler:
          enabled: true
        
        frontendWorker:
          enabled: true
        
        backend:
          enabled: false
          replicas: 0
        
        read:
          enabled: false
          replicas: 0
        
        write:
          enabled: false
          replicas: 0
        EOT
    ]

    depends_on = [
        aws_iam_role_policy_attachment.loki_policy_attachment,
        aws_s3_bucket.loki_storage
    ]
}
*/
 /*
resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  version          = var.loki_chart_version
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = false  # Set to false to debug installation issues
  cleanup_on_fail  = true
  timeout          = 300

  # Use a values file instead of inline values
  values = [
    templatefile("${path.module}/loki-values.yaml", {
      loki_service_account_name = var.loki_service_account_name
      loki_role_arn = aws_iam_role.loki_role.arn
      s3_bucket_name = aws_s3_bucket.loki_storage.id
      aws_region = data.aws_region.current.id
      ebs_storage_class_name = var.ebs_storage_class_name
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
  namespace        = var.k8s_namespace
  create_namespace = true
  atomic           = false
  cleanup_on_fail  = true
  timeout          = 300

values = [
  yamlencode({
    deploymentMode = "Distributed"
    # ... (other settings remain the same) ...
    loki = {
      auth_enabled = false
      commonConfig = { replication_factor = 1 }

      # Structured configuration replaces both 'config' string and separate blocks
      structuredConfig = {
        limits_config = {
          allow_structured_metadata = true
        }
        schema_config = {
          configs = [
            {
              from         = "2024-01-01"
              store        = "tsdb"
              object_store = "aws"
              schema       = "v13"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }
        storage_config = {
          aws = {
            s3               = "s3://${aws_s3_bucket.loki_storage.id}"
            region           = data.aws_region.current.id
            s3forcepathstyle = true
          }
          # Moved shared_store to index_shipper
          #shared_store = "aws"
          tsdb_shipper = {
            active_index_directory = "/var/loki/index"
            cache_location         = "/var/loki/cache"
            #shared_store           = "aws"
          }
        }
      }

      # Keep storage settings for Helm chart internals
      storage = {
        #type = "s3"  # Add storage type
        bucketNames = {
          chunks = aws_s3_bucket.loki_storage.id
          ruler  = aws_s3_bucket.loki_storage.id
          admin  = aws_s3_bucket.loki_storage.id
        }
      }
    }
    distributor = {
        replicas       = 2
        maxUnavailable = 1
      }

      ingester = {
        replicas = 2
        persistence = {
          enabled      = true
          size         = "10Gi"
          storageClass = var.ebs_storage_class_name
        }
      }

      querier = {
        replicas       = 2
        maxUnavailable = 1
      }

      queryFrontend = {
        replicas       = 2
        maxUnavailable = 1
      }

      compactor = {
        enabled                       = true
        retention_enabled             = true
        retention_delete_delay        = "2h"
        retention_delete_worker_count = 150
        working_directory             = "/var/loki/compactor"
        shared_store                  = "aws"
      }

      ruler = {
        enabled  = true
        replicas = 1
        directories = {
          rules = "/etc/loki/rules"
        }
      }

      gateway = {
        enabled = true
      }

      queryScheduler = {
        enabled = true
      }

      frontendWorker = {
        enabled = true
      }

      backend = {
        enabled  = false
        replicas = 0
      }

      read = {
        enabled  = false
        replicas = 0
      }

      write = {
        enabled  = false
        replicas = 0
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.loki_policy_attachment,
    aws_s3_bucket.loki_storage
  ]
}



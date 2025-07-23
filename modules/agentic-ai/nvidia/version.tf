terraform {
  required_version = ">= 1.7.5"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 3.0.0"
    }
  }
}
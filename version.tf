terraform {
  required_version = ">= 1.7.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.0"
    }
    local      = ">= 2.5.1"
    random     = ">= 3.7.2"
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.37.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
}


/*
variable "cluster_id" {
    description    =  "Put your cluster id here"
}

variable "vpc_id" {
  description      =  "put your vpc id"
}

variable "cluster_name" {
  description      =   "put your cluster name here"
}

*/
variable "app_namespace" {
   description      =   "Kubernetes namespace name in which the application will be deployed "
   type = string
   default = null
}

variable "create_namespace" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}


# -------------------
# VARIABLES
# -------------------
variable "namespace" {
  default = var.app_namespace
}

variable "image" {
  default = "alexwhen/docker-2048:latest"
}

variable "replicas" {
  default = 5
}

variable "ingress_hostname" {
  description = "The DNS name to access the app via Ingress (e.g., 2048.example.com)"
  type        = string
}

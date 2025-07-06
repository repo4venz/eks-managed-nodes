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
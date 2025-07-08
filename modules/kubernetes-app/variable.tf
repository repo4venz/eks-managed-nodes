 
variable "app_namespace" {
   description      =   "Kubernetes namespace name in which the application will be deployed "
   type = string
   default = "myapps1"
}

variable "create_namespace" {
  type        = bool
  default     = false
  description = "Execute module or not. true = execute and false = don't execute"
}


# -------------------
# VARIABLES
# -------------------
 

variable "image" {
  default = "alexwhen/docker-2048:latest"
}

variable "replicas" {
  default = 5
}

variable "ingress_hostname" {
  description = "The DNS name to access the app via Ingress (e.g., 2048.example.com)"
  type        = string
  default = "game-app.suvendu.public-dns.aws"
}

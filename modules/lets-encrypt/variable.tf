
variable "email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "suvendu.mandal@gmail.com"
}

variable "enable_lets_encrypt_ca" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}
 
 
variable "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  type        = string
  default = "Z00719261GUBMEJWEC48W"   # AWS Route 553 Public Hosted Zone -- Zone ID
}

variable "environment" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default = "test"
}

/*
variable "lets_encrypt_server_url" {
  description = "Environemnt of Lets Encrypt"
  type        = string
  default =  "https://acme-staging-v02.api.letsencrypt.org/directory"
  }
*/

locals{
  lets_encrypt_server_url = var.environment == "prod" ? "https://acme-v02.api.letsencrypt.org/directory"  : "https://acme-staging-v02.api.letsencrypt.org/directory"
}

 

 


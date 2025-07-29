variable "k8s_cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}
 
 variable enable_vpc_cni_advance_network {
  default = false
  type = bool
  description = "Enable / Disable VPC CNI Advance networking using prefix delegation or IP target"
 }


variable "vpc_cni_prefix_delegation_configs" {
  type = object({
    enable_prefix_delegation = string
    warm_eni_target     = string
    warm_prefix_target  = string
    warm_ip_target      = string
    minimum_ip_target   = string
  })
  description = "VPC CNI Advance networking configs"
  default = {
    enable_prefix_delegation = "true"   
    warm_eni_target     = "1"
    warm_prefix_target  = "1"   # Warm up 1 prefix
    warm_ip_target      = "0"   # Warm up n IPs.
    minimum_ip_target   = "0"
  }
}
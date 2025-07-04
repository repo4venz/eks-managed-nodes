variable "environment" {}
variable "cluster_name" {}

variable "cluster_group" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnets_cidr" {}
variable "availability_zones_public" {}
variable "private_subnets_cidr" {}
variable "availability_zones_private" {}
variable "cidr_block_internet_gw" {}
variable "cidr_block_nat_gw" {}

variable aws_admin_role_name {
  description = "AWS Admin Role to manage EKS cluster. The role must be created in AWS with required permission."
  default = "eks_admin_role"
}
variable aws_admin_user_name {
  description = "AWS User who will assume AWS Admin Role to manage EKS cluster. The user must be created in AWS to assume the admin role."
  default = "eks_admin_user"
}
 
variable "cluster_version" {}
variable "region_name" {
  description = "AWS Region code"
  default = "eu-west-2"
}
variable "user_profile" {
  description = "AWS User profile to execute commands"
  default = "default"
}
variable "user_os" {
  description = "Operating system used by user to execute Terraform, Kubectl, aws commands. e.g. \"windows\" or \"linux\""
}

variable "github_runner_base_path" {
  description = "GitHub Actions Runner Base path for Linux"
  type = string
  default = "/home/runner/"
}

 
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags e.g. `map('BusinessUnit`,`XYZ`)"
}


variable "include_nginx_controller_module" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}


variable "include_eks_cluster_autoscaler" {
  type        = bool
  default     = true
  description = "Execute module or not. true = execute and false = don't execute"
}
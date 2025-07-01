 
provider "aws" {
  region     = var.region_name
  default_tags {
   tags = {
     Owner = "Suvendu Mandal"
     Owner_Email       = "suvendu.mandal@gmail.com"
     Owner_Group     = "Personal"
     Owner_Location     = "UK"
     Environment =  var.environment
     Resource_Region = var.region_name
     EKS_Cluster_Name = "${var.cluster_name}-${var.environment}"
   }
 }
}



 terraform {
  backend "s3" {
    bucket = "suvendu-terraform-state" #var.s3_bucket_name
    key    = "eks/terraform.tfstate" #var.tfstate_file_path
    region = var.region_name
    encrypt= true
  }
}
 

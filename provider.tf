 
provider "aws" {
  region     = var.region_name
  default_tags {
   tags = {
     Owner = "Suvendu Mandal"
     Owner_Email       = "suvendu.mandal@gmail.com"
     Owner_Group     = "Personal"
     Owner_Location     = "UK"
     Purpose = "eks_agentic_ai"
     Environment =  var.environment
     Resource_Region = var.region_name
     EKS_Cluster_Name = "${var.cluster_name}-${var.environment}"
   }
 }
}



 terraform {
  backend "s3" {
    bucket = "suvendu-terraform-state-all" #var.s3_bucket_name
    key    = "eks/terraform.tfstate" #var.tfstate_file_path
    region = "eu-west-2" #var.region_name   ### Mentioned fixed region for s3 bucket
    encrypt= true
  }
}
 

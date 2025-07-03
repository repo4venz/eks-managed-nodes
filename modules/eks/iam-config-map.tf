


# Example of a local-exec provisioner to verify cluster readiness
resource "null_resource" "wait_for_cluster" {

  	  triggers = {
	    always_run = timestamp()
	  }

  provisioner "local-exec" {
    command = "aws eks wait cluster-active --name ${aws_eks_cluster.demo_eks_cluster.name} --region ${data.aws_region.current.name}"
    # Use `kubectl` commands to verify the cluster's status after it's active
    # Example:
    # command = "kubectl get nodes && kubectl get pods -A"
  }
  depends_on = [aws_eks_cluster.demo_eks_cluster]
}


# Update the Kubeconfig file in the GitHub Actions Runner
resource "null_resource" "eks_get_config_exec" {
	
	  triggers = {
	    always_run = timestamp()
	  }
	  provisioner "local-exec" {
	    command = "aws eks --region ${data.aws_region.current.name} update-kubeconfig --name ${aws_eks_cluster.demo_eks_cluster.name}"
	  }
	
	  depends_on = [
	    aws_eks_cluster.demo_eks_cluster,
      null_resource.wait_for_cluster
	  ]
	}



/*
# Update the Kubeconfig file in the GitHub Actions Runner
resource "null_resource" "eks_delete_configmap_exec" {
	
	  triggers = {
	    always_run = timestamp()
	  }
	  provisioner "local-exec" {
	    command = "kubectl delete configmap aws-auth -n kube-system"
	  }
	
	  depends_on = [
	    null_resource.eks_get_config_exec
	  ]
	}
*/


# Define the aws-auth configmap
#resource "kubernetes_config_map" "aws_auth" {
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = yamlencode([
      {
        rolearn  = "arn:aws:iam::717949064245:role/suvendu-super-admin-role"
        username = "suvendu-super-admin-role"
        groups   = ["system:masters"]
      },
      # Add more roles or users here
    ])
    "mapUsers" = yamlencode([
      {
        userarn  = "arn:aws:iam::717949064245:user/suvendu_cli_super_admin"
        username = "suvendu_cli_super_admin"
        groups   = ["system:masters"]
      },
      {
        userarn  = "arn:aws:iam::717949064245:user/suvendu-github-user"
        username = "suvendu-github-user"
        groups   = ["system:masters"]
      },
    ])
  }

  	  depends_on = [
        null_resource.eks_get_config_exec
	  ]
}


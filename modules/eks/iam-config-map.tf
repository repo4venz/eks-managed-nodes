


# Example of a local-exec provisioner to verify cluster readiness
resource "null_resource" "wait_for_cluster" {

  	  triggers = {
	    always_run = timestamp()
	  }

  provisioner "local-exec" {
    command = "aws eks wait cluster-active --name ${aws_eks_cluster.demo_eks_cluster.name} --region ${data.aws_region.current.id}"
    # Use `kubectl` commands to verify the cluster's status after it's active
    # Example:
    # command = "kubectl get nodes && kubectl get pods -A"
  }
  depends_on = [aws_eks_cluster.demo_eks_cluster]
}

resource "time_sleep" "wait_120_seconds" {
  create_duration = "120s"  # 2 minutes

  depends_on = [aws_eks_cluster.demo_eks_cluster ]
}


# Update the Kubeconfig file in the GitHub Actions Runner
resource "null_resource" "eks_get_config_exec" {
	
	  triggers = {
	    always_run = timestamp()
	  }
	  provisioner "local-exec" {
	    command = "aws eks update-kubeconfig --region ${data.aws_region.current.id} --name ${aws_eks_cluster.demo_eks_cluster.name}"
	  }
	
	  depends_on = [
	    aws_eks_cluster.demo_eks_cluster,
      null_resource.wait_for_cluster,
      time_sleep.wait_120_seconds
	  ]
	}



 
# Describe existing Config Map aws-auth  
resource "null_resource" "eks_describe_existing_configmap_exec" {
	
	  triggers = {
	    always_run = timestamp()
	  }
	  provisioner "local-exec" {
	    command = "kubectl describe configmap -n kube-system aws-auth"
	  }
	
	  depends_on = [
	      null_resource.eks_get_config_exec,
        null_resource.wait_for_cluster,
        aws_eks_cluster.demo_eks_cluster,
        aws_eks_node_group.demo_eks_nodegroup_spot   #wait for cluster to initialise - aws_auth must be initialised first before any update
	  ]
	}
 

 ##### ConfigMap will only use the First attribute mentioned in the list string for admin role and users. Refer EKS Access Entries for all types of authentication #######
 ######################################################################################################################################################################

# Update existing the aws-auth configmap
#resource "kubernetes_config_map" "aws_auth" {
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  force = true
  data = {
    "mapRoles" = yamlencode([
      {
        rolearn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_admin_role_name[0]}"
        username = "${var.aws_admin_role_name[0]}"
        groups   = ["system:masters", "system:bootstrappers", "system:nodes"]
      },
      {
        rolearn  = "${aws_iam_role.eks_worker_nodes_role.arn}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      } 
      # Add more roles or users here
    ])
    "mapUsers" = yamlencode([
      {
        userarn  = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_admin_user_name[0]}"
        username = "${var.aws_admin_user_name[0]}"
        groups   = ["system:masters"]
      },
      {
        userarn  = "${aws_iam_role.eks_worker_nodes_role.arn}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [ "system:bootstrappers", "system:nodes"]
      }
    ])
  }

  	  depends_on = [
        null_resource.eks_get_config_exec,
        null_resource.wait_for_cluster,
        aws_eks_cluster.demo_eks_cluster,
        aws_eks_node_group.demo_eks_nodegroup_spot,  #wait for cluster to initialise - aws_auth must be initialised first before any update
	      aws_eks_node_group.demo_eks_nodegroup_ondemand
    ]
}



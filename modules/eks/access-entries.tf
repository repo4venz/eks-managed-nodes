 #aws eks list-access-policies --output table

 
############################# Admin User Roles ####################################################

resource "aws_eks_access_entry" "admin_role" {
  count = length(var.aws_admin_role_names)

  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  principal_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_admin_role_names[count.index]}"

  # Optional: Specify Kubernetes username and groups
 # kubernetes_groups = ["system:masters"]
 # user_name         = "admin-role-${var.aws_admin_role_names[count.index]}"
  
  type = "STANDARD"

   depends_on = [ aws_eks_cluster.demo_eks_cluster  ]
}

## Access Policies (RBAC permissions)
resource "aws_eks_access_policy_association" "admin_policy_roles" {
  count = length(var.aws_admin_role_names)

  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_role[count.index].principal_arn

  access_scope {
    type = "cluster"
  }
}



############################# Admin Users Only ####################################################

resource "aws_eks_access_entry" "admin_user" {
  count = length(var.aws_admin_user_names)

  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  principal_arn = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:user/${var.aws_admin_user_names[count.index]}"

  # Optional: Specify Kubernetes username and groups
 # kubernetes_groups = ["system:masters"]
 # user_name         = "admin-role-${var.aws_admin_user_names[count.index]}"
  
  type = "STANDARD"
  depends_on = [ aws_eks_cluster.demo_eks_cluster  ]
}


## Access Policies (RBAC permissions)
resource "aws_eks_access_policy_association" "admin_policy_users" {
  count = length(var.aws_admin_user_names)

  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.admin_user[count.index].principal_arn

  access_scope {
    type = "cluster"
  }
}


#############################  Worker Nodes ####################################################

 resource "aws_eks_access_entry" "worker_nodes" {
  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  principal_arn = aws_iam_role.eks_worker_nodes_role.arn # Actual node role
  user_name     = "system:node:{{EC2PrivateDNSName}}"
  type          = "EC2_LINUX"
  depends_on = [ aws_eks_cluster.demo_eks_cluster  ]
}

 resource "aws_eks_access_policy_association" "worker_nodes_policy" {
  cluster_name  = aws_eks_cluster.demo_eks_cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSWorkerNodePolicy"
  principal_arn = aws_eks_access_entry.worker_nodes.principal_arn

  access_scope {
    type = "cluster"
  }
}

 



/*
resource "aws_eks_access_entry" "dev_team" {
  cluster_name  = aws_eks_cluster.example.name
  principal_arn = "arn:aws:iam::123456789012:group/DevTeam"

  kubernetes_groups = ["developers"]
  user_name         = "dev-team"
  
  type = "STANDARD"
}



resource "aws_eks_access_entry" "ci_cd" {
  cluster_name  = aws_eks_cluster.example.name
  principal_arn = "arn:aws:iam::123456789012:role/CI-CD-Role"

  kubernetes_groups = ["ci-cd"]
  user_name         = "ci-cd-system"
  
  type = "STANDARD"
}
*/


/*

resource "aws_eks_access_policy_association" "dev_policy" {
  cluster_name  = aws_eks_cluster.example.name
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_eks_access_entry.dev_team.principal_arn

  access_scope {
    type       = "namespace"
    namespaces = ["development"]
  }
}

resource "aws_eks_access_policy_association" "ci_cd_policy" {
  cluster_name  = aws_eks_cluster.example.name
  policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
  principal_arn = aws_eks_access_entry.ci_cd.principal_arn

  access_scope {
    type       = "namespace"
    namespaces = ["default", "production"]
  }
}

*/
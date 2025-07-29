 
resource "aws_iam_role" "vpc_cni_irsa_role" {
  name  = substr("${var.k8s_cluster_name}-vpc-cni-irsa-role",0,64)
  description = "IAM Role for VPC CNI"
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume.json
}

 
 
resource "aws_iam_role_policy_attachment" "vpc_cni_attach" {
  role       = aws_iam_role.vpc_cni_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


#https://aws.amazon.com/blogs/containers/amazon-vpc-cni-increases-pods-per-node-limits/
resource "aws_eks_addon" "vpc_cni" {

  cluster_name                = data.aws_eks_cluster.this.name
  addon_name                  = data.aws_eks_addon_version.vpc_cni.addon_name
  addon_version               = data.aws_eks_addon_version.vpc_cni.version # optional (e.g. "v1.16.0-eksbuild.1")
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.vpc_cni_irsa_role.arn
  

  configuration_values = jsonencode({
    env = merge(
      var.enable_vpc_cni_advance_network ? {
        ENABLE_PREFIX_DELEGATION = var.vpc_cni_prefix_delegation_configs.enable_prefix_delegation
        WARM_ENI_TARGET          = var.vpc_cni_prefix_delegation_configs.warm_eni_target
        WARM_PREFIX_TARGET       = var.vpc_cni_prefix_delegation_configs.warm_prefix_target
        WARM_IP_TARGET           = var.vpc_cni_prefix_delegation_configs.warm_ip_target
        MINIMUM_IP_TARGET        = var.vpc_cni_prefix_delegation_configs.minimum_ip_target
      } : {}
    )
  })
 
  depends_on = [
    aws_iam_role_policy_attachment.vpc_cni_attach,
    aws_iam_role.vpc_cni_irsa_role
  ]
}
 

/*
Variable	Recommended Value	 
enable_vpc_cni_advance_network	true	Uses /28 IPv4 prefixes (reduces API calls, improves scaling).
WARM_IP_TARGET	5	Pre-allocates 5 IPs to reduce pod startup latency (good for moderate churn).
WARM_ENI_TARGET	1	Keeps 1 extra ENI "warmed up" (helps sudden scaling needs).
WARM_PREFIX_TARGET	1 (not 2)	Warms 1 prefix (16 IPs) instead of 2 (avoids wasting IPs).
MINIMUM_IP_TARGET	10 (optional)	Ensures at least 10 IPs are always available (prevents throttling).

warm_ip_target and warm_prefix_target are mutually exclusive

minimum_ip_target and warm_prefix_target are mutually exclusive


Key Adjustments & Rationale
WARM_PREFIX_TARGET=1 (not 2)

Each prefix = 16 IPs. Warming 2 prefixes (32 IPs) is overkill for most workloads and wastes IPs.

Exception: Use 2 only if you need instant scaling for 30+ pods simultaneously.

MINIMUM_IP_TARGET=10 (Optional)

Guarantees a buffer of IPs, preventing delays when pods scale up abruptly.

Adjust based on your average pod churn rate.

Avoid Over-Allocation

WARM_ENI_TARGET=1 is sufficient (warming more ENIs consumes extra IPs unnecessarily).



Performance vs. Cost Tradeoffs
Config	Pros	Cons
WARM_PREFIX_TARGET=1	Balances speed/IP efficiency	Slight delay if scaling >16 pods at once
WARM_PREFIX_TARGET=2	Faster scaling for bursts	Wastes 16+ IPs (higher AWS cost)
MINIMUM_IP_TARGET=10	Prevents throttling	Slightly fewer available IPs for pods


*/
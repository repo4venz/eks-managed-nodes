output "debug_spot_node_groups_max_pods" {
  value = local.spot_node_groups_max_pods
}

output "debug" {
  value = {
    base_max_pods = local.max_pods
    node_config   = local.spot_node_groups_max_pods
    validated     = local.validated_max_pods
  }
}
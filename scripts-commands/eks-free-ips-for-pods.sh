#!/bin/bash

echo "Collecting pod IPs per EKS node..."

# Map of node name => pod IPs
declare -A node_pod_ips

# Populate node_pod_ips from Kubernetes
while IFS=$'\t' read -r node ip; do
  node_pod_ips["$node"]+="$ip "
done < <(kubectl get pods -A -o jsonpath='{range .items[*]}{.spec.nodeName}{"\t"}{.status.podIP}{"\n"}{end}')

# Process each node
for node in $(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
  echo "============================"
  echo "Node: $node"

  # Get EC2 instance ID for node
  instance_id=$(kubectl get node "$node" -o jsonpath='{.spec.providerID}' | cut -d'/' -f5)
  echo "Instance ID: $instance_id"

  # Get ENIs attached to this instance
  eni_ids=$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query "Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId" \
    --output text)

  used_ips=()
  total_ips=()
  
  for eni in $eni_ids; do
    # Get all private IPs on this ENI
    ips=$(aws ec2 describe-network-interfaces \
      --network-interface-ids "$eni" \
      --query "NetworkInterfaces[0].PrivateIpAddresses[*].PrivateIpAddress" \
      --output text)
    
    for ip in $ips; do
      total_ips+=("$ip")
    done
  done

  # Get pod IPs running on this node
  pod_ips=(${node_pod_ips["$node"]})

  echo "Total ENI IPs: ${#total_ips[@]}"
  echo "Used by pods: ${#pod_ips[@]}"

  # Show free IPs (ENI IPs not used by pods)
  free_ips=()
  for eni_ip in "${total_ips[@]}"; do
    if [[ ! " ${pod_ips[@]} " =~ " ${eni_ip} " ]]; then
      free_ips+=("$eni_ip")
    fi
  done

  echo "Free IPs available for pods (${#free_ips[@]}):"
  printf '  %s\n' "${free_ips[@]}"
  echo ""
done


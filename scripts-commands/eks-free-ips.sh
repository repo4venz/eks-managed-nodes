#!/bin/bash

CLUSTER_NAME="eks-managed-clstr-dev"
TAG_KEY="kubernetes.io/cluster/$CLUSTER_NAME"
TAG_VALUE="owned"

echo "Finding EC2 nodes for cluster: $CLUSTER_NAME"

# Get EC2 instance IDs of EKS worker nodes
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

total_free_ips=0

for instance_id in $instance_ids; do
  echo "Instance ID: $instance_id"

  eni_ids=$(aws ec2 describe-instances \
    --instance-ids "$instance_id" \
    --query "Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId" \
    --output text)

  for eni_id in $eni_ids; do
    echo "  ENI ID: $eni_id"

    total_ips=$(aws ec2 describe-network-interfaces \
      --network-interface-ids "$eni_id" \
      --query "NetworkInterfaces[0].PrivateIpAddresses" \
      --output json | jq length)

    assigned_ips=$(aws ec2 describe-network-interfaces \
      --network-interface-ids "$eni_id" \
      --query "NetworkInterfaces[0].PrivateIpAddresses[?Association==null]" \
      --output json | jq length)

    free_ips=$((total_ips - assigned_ips))
    total_free_ips=$((total_free_ips + free_ips))

    echo "    Total IPs: $total_ips"
    echo "    In use:    $assigned_ips"
    echo "    Free IPs:  $free_ips"
    echo ""
  done
done

echo "==============================="
echo "Total FREE IPs across all EKS nodes: $total_free_ips"

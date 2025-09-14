#!/bin/bash

echo "Input the EKS Cluster name:"
read eks_cluster_name
 

eks_cluster_name=${eks_cluster_name:"eks-managed-clstr-dev"}

eks_cluster_tag="kubernetes.io/cluster/$eks_cluster_name"

instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag-key,Values=$eks_cluster_tag" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

for instance_id in $instance_ids; do
  echo "Instance ID: $instance_id"

  for eni in $(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --query "Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId" \
  --output text); do

 
    echo "  Network Interface ID: $eni"

    aws ec2 describe-network-interfaces \
    --network-interface-ids "$eni" \
    --query "NetworkInterfaces[0].{ENI:NetworkInterfaceId, PrivateIPs:PrivateIpAddresses[*].PrivateIpAddress, Prefixes:Ipv4Prefixes[*].Ipv4Prefix}" \
    --output table
	  
    echo ""
  done
done
 

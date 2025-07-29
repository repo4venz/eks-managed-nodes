#!/bin/bash

echo "Input the EKS Cluster name:"
read eks_cluster_name

total_ips=0
assigned_ips=0
free_ips=0

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
      --query "NetworkInterfaces[0].PrivateIpAddresses[*].{Primary:Primary,Address:PrivateIpAddress}" \
      --output table
	  
	  # Get number of total and used IPs on this ENI
	total_ips_per_eni=$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$eni" \
    --query "NetworkInterfaces[0].PrivateIpAddresses" \
    --output json | jq length)

	assigned_ips_per_eni=$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$eni" \
    --query "NetworkInterfaces[0].PrivateIpAddresses[?Association==null]" \
    --output json | jq length)

	total_ips=$((total_ips + total_ips_per_eni))
	assigned_ips=$((assigned_ips + assigned_ips_per_eni))

    echo ""
  done
done

free_ips=$((total_ips - assigned_ips))

echo "Total IPs assigned accross all ENIs: $total_ips"
echo "IPs in use (primary + pods) accross all ENIs: $assigned_ips"
 echo "FREE IPs available accross all ENIs: $free_ips"

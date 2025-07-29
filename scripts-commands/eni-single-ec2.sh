#!/bin/bash


echo "Provide the EC2 Instance ID  (eg. i-0bae8e699cec6b30e)"
read ec2_instance_id

for eni in $(aws ec2 describe-instances \
  --instance-ids $ec2_instance_id \
  --query "Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId" \
  --output text); do
  
  echo "Network Interface ID: $eni"
  
  aws ec2 describe-network-interfaces \
    --network-interface-ids "$eni" \
    --query "NetworkInterfaces[0].PrivateIpAddresses[*].{Primary:Primary,Address:PrivateIpAddress}" \
    --output table
  
  echo ""
done


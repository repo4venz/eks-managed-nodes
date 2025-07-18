#!/bin/bash

# Get the problematic PV
PV_NAME="pvc-f073b986-2b0f-400b-ad97-d49820245a32"
echo "Backing up original PV configuration..."
kubectl get pv $PV_NAME -o yaml > pv-backup.yaml

# Get the EBS volume ID
VOLUME_ID=$(kubectl get pv $PV_NAME -o jsonpath='{.spec.csi.volumeHandle}')
echo "Found EBS volume ID: $VOLUME_ID"

# Get the storage class
STORAGE_CLASS=$(kubectl get pv $PV_NAME -o jsonpath='{.spec.storageClassName}')
echo "Storage class: $STORAGE_CLASS"

# Get the claim reference
CLAIM_NAMESPACE=$(kubectl get pv $PV_NAME -o jsonpath='{.spec.claimRef.namespace}')
CLAIM_NAME=$(kubectl get pv $PV_NAME -o jsonpath='{.spec.claimRef.name}')
echo "PVC: $CLAIM_NAMESPACE/$CLAIM_NAME"

# Get available zones
ZONES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.labels.topology\.kubernetes\.io/zone}' | tr ' ' '\n' | sort | uniq | tr '\n' ' ')
echo "Available zones: $ZONES"

# Update the fix-pv-node-affinity.yaml file with actual values
sed -i "s/vol-xxxxxxxxxxxx/$VOLUME_ID/g" fix-pv-node-affinity.yaml

# Delete the problematic PV (this will not delete the underlying EBS volume)
echo "Deleting problematic PV..."
kubectl delete pv $PV_NAME

# Apply the fixed PV definition
echo "Creating PV with fixed node affinity..."
kubectl apply -f fix-pv-node-affinity.yaml

# Restart the Prometheus pod
echo "Restarting Prometheus pod..."
kubectl delete pod -n monitoring prometheus-kube-prometheus-kube-prome-prometheus-0

echo "Done! Check the status of the Prometheus pod:"
kubectl get pods -n monitoring
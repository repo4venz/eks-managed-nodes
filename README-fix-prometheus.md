# Fixing Prometheus PV Node Affinity Issue

The error you're seeing is related to persistent volume scheduling issues with Prometheus in your EKS cluster. The problem is that the PersistentVolume has node affinity settings that don't match the nodes available in your cluster.

## Root Cause

The error occurs because:

1. The PersistentVolume was created with specific node affinity settings (likely tied to the availability zone where the EBS volume was created)
2. The Prometheus pod is being scheduled on a node that doesn't match these affinity settings
3. The storage class is using `Immediate` binding mode instead of `WaitForFirstConsumer`

## Solution

There are two approaches to fix this issue:

### Approach 1: Fix the existing PV (Short-term fix)

Run the provided script to fix the node affinity on the existing PV:

```bash
chmod +x fix-prometheus-scheduling.sh
./fix-prometheus-scheduling.sh
```

This script will:
1. Back up the current PV configuration
2. Get the EBS volume ID and other details
3. Delete the PV (but not the underlying EBS volume)
4. Create a new PV with more flexible node affinity settings
5. Restart the Prometheus pod

### Approach 2: Use proper storage classes (Long-term fix)

1. Apply the new storage classes with `WaitForFirstConsumer` binding mode:

```bash
terraform apply -target=module.storage
```

2. Update your Prometheus Helm release to use the new storage class:

```bash
helm upgrade prometheus prometheus-community/kube-prometheus-stack -f prometheus-values.yaml -n monitoring
```

The `prometheus-values.yaml` file configures Prometheus to use the `ebs-sc` storage class, which uses `WaitForFirstConsumer` binding mode. This ensures that the PV is only created after the pod is scheduled to a node, avoiding node affinity issues.

## Prevention

To prevent this issue in the future:

1. Always use storage classes with `WaitForFirstConsumer` binding mode for EBS volumes
2. Install the AWS EBS CSI Driver properly with the correct IAM permissions
3. Use the provided storage module in your Terraform code

## Additional Notes

- The `WaitForFirstConsumer` binding mode delays volume binding until a pod using the PVC is scheduled
- This ensures the volume is created in the same availability zone as the node where the pod is scheduled
- The AWS EBS CSI Driver is required for dynamic provisioning of EBS volumes
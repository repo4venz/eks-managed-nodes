# EFS CSI Driver for Cross-AZ Persistent Volumes in EKS

This module deploys the AWS EFS CSI Driver on your EKS cluster using Helm and sets up an EFS file system for cross-AZ persistent volumes.

## Why EFS for Cross-AZ Access?

EBS volumes are zone-specific and cannot be attached to nodes in different availability zones. EFS provides a shared file system that can be accessed from multiple AZs, making it ideal for:

- Stateful applications that need to run across multiple AZs
- Applications that need shared storage across multiple pods
- Use cases requiring ReadWriteMany access mode

## Usage

Add the EFS storage module to your Terraform configuration:

```hcl
module "efs_storage" {
  source = "./modules/efs-storage"
  
  cluster_name                  = module.eks.cluster_name
  vpc_id                        = module.vpc.vpc_id
  private_subnet_ids            = module.vpc.private_subnets
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
}
```

## Testing EFS Storage

1. Apply the example PVC:
```bash
kubectl apply -f efs-example-pvc.yaml
```

2. Deploy a test pod:
```bash
kubectl apply -f efs-example-pod.yaml
```

3. Verify the pod can write to the EFS volume:
```bash
kubectl exec efs-app -- cat /data/out.txt
```

## Notes

- EFS provides shared storage with ReadWriteMany access mode
- EFS performance may be lower than EBS for some workloads
- For applications requiring high IOPS, consider using EBS volumes with node affinity
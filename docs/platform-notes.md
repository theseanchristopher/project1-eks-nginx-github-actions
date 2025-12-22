# Platform Notes — Project 1

This project assumes the existence of an Amazon EKS cluster that was created prior to application development.

## Cluster Baseline

The EKS cluster used for Project 1 was created using `eksctl` with the following characteristics:

- Managed node group (EC2)
- IAM authentication enabled
- Kubernetes API access configured via `aws eks update-kubeconfig`
- AWS Load Balancer Controller installed to support ALB-backed Ingress resources

## Assumptions

This repository assumes:

- The EKS cluster already exists
- Local kubeconfig access is configured for the cluster
- GitHub Actions has AWS credentials with permissions for:
  - Amazon ECR (image push)
  - Amazon EKS (kubectl apply and rollout status)
  - Related IAM and networking resources

## Scope Note

Cluster creation and lifecycle management are intentionally out of scope for this repository.

Subsequent projects in this series replace this manual setup with infrastructure-as-code (Terraform) and GitOps-based platform management.

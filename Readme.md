# Bank App Infrastructure Deployment

This repository contains Terraform code to provision a complete AWS-based infrastructure for a banking application. The infrastructure includes **EKS (Kubernetes) cluster**, **RDS (PostgreSQL)**, **ECR repositories** for Docker images, **NGINX Ingress**, **Cert-Manager with ClusterIssuer**, and **ArgoCD** for GitOps-based deployment.

---

## Overview

The Terraform deployment performs the following:

1. **VPC & Networking**
   - Creates a VPC with public and private subnets.
   - Private subnets host the RDS instance and EKS worker nodes.
   - Security groups are configured to allow required traffic between components.

2. **EKS Cluster**
   - Uses the `terraform-aws-modules/eks/aws` module.
   - Deploys managed node groups with proper IAM roles.
   - Installs core add-ons: `coredns`, `kube-proxy`, and `vpc-cni`.

3. **RDS PostgreSQL**
   - Creates an RDS instance in private subnets.
   - Configured with a security group that allows access from EKS nodes.
   - Stores the database credentials as Kubernetes secrets for pods to use.

4. **ECR Repositories**
   - Two repositories are created for the **frontend** and **backend** Docker images.
   - These images can be built and pushed to ECR, then deployed via Kubernetes manifests.

5. **NGINX Ingress Controller**
   - Installed via Helm in the `ingress-nginx` namespace.
   - Provides LoadBalancer service for external access to the apps.
   - Integrated with Route53 to handle subdomain DNS entries dynamically.

6. **Cert-Manager & ClusterIssuer**
   - Cert-Manager installed via Helm in `cert-manager` namespace.
   - Configures a `ClusterIssuer` using ACME (Let's Encrypt) for automatic TLS certificates.
   - Ensures secure HTTPS access for subdomains.

7. **ArgoCD**
   - Deployed via Helm in `argocd` namespace.
   - Configured with Ingress and TLS using the same NGINX controller.
   - Provides GitOps-based deployment for Kubernetes manifests.
   - **Retrieve initial admin password:**
     ```bash
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
     ```

8. **Route53 DNS**
   - Configures subdomains for:
     - `bank.<domain>` → Frontend
     - `bankapi.<domain>` → Backend
     - `argocd.<domain>` → ArgoCD UI
   - Uses the LoadBalancer hostname from NGINX Ingress automatically.

---

## Repository Links

- **Frontend application:** [Bank-app-Frontend](https://github.com/canepro/Bank-app-Frontend)  
- **Backend application:** [Bank-app-Backend](https://github.com/canepro/Bank-app-Backend)  
- **Kubernetes manifests:** [Banking-app-with-K8s](https://github.com/canepro/banking-app-with-k8s)

---

## How It Works

1. **Terraform applies** the infrastructure, creating all AWS resources.
2. **Helm deploys** NGINX Ingress, Cert-Manager, and ArgoCD.
3. **ClusterIssuer** configures TLS certificates for subdomains automatically.
4. **Route53 records** point the subdomains to the NGINX LoadBalancer.
5. **Kubernetes manifests** (from your GitHub repo) deploy the backend and frontend apps on the EKS cluster, using RDS for persistent storage.

---

## Requirements

- Terraform >= 1.5
- AWS account with IAM permissions for:
  - EKS, EC2, RDS, ECR, Route53, IAM
- kubectl configured (optional if using Terraform-only)
- Helm >= 3.0

---

## Notes

- All sensitive data (like DB passwords) is stored securely as Terraform variables and Kubernetes secrets.
- The deployment is fully automated; no manual steps are required for EKS, RDS, or Ingress.
- For GitOps, ArgoCD watches the Kubernetes manifest repo and deploys the applications automatically.

---

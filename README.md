# EKS with Dynamic EBS Provisioning

This repository provides Terraform code and Kubernetes manifests to deploy an Amazon EKS (Elastic Kubernetes Service) cluster with dynamic EBS (Elastic Block Store) volume provisioning using the AWS EBS CSI driver.

---

## Table of Contents

- [Project Structure](#project-structure)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Configure AWS Credentials](#2-configure-aws-credentials)
  - [3. Initialize and Apply Terraform](#3-initialize-and-apply-terraform)
  - [4. Configure kubectl](#4-configure-kubectl)
  - [5. Deploy Kubernetes Manifests](#5-deploy-kubernetes-manifests)
- [File Descriptions](#file-descriptions)
- [Outputs](#outputs)
- [Cleanup](#cleanup)
- [References](#references)
- [Testing the EBS Persistent Volume](#testing-the-ebs-persistent-volume)

---

## Project Structure

```
iam.tf
main.tf
outputs.tf
providers.tf
security-group.tf
variables.tf
versions.tf
vpc.tf
KS8-manfifests/
    persistent-volume-claim.yaml
    service.yaml
    statefulset.yaml
    storage-class.yaml
```


## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate permissions)
- AWS account with permissions to create EKS, VPC, IAM, and EBS resources
- Windows OS (Tested on Windows as of May 16, 2025)

---

## Setup Instructions

### 1. Clone the Repository

```sh
git clone https://github.com/your-username/eks-ebs-dynamic-provisioning.git
cd eks-ebs-dynamic-provisioning
```

### 2. Configure AWS Credentials

Ensure your AWS credentials are set up. You can use environment variables, the AWS credentials file, or AWS SSO.

```sh
aws configure
```

### 3. Initialize and Apply Terraform

```sh
terraform init
terraform apply
```

- Review the plan and type `yes` to confirm.
- This will create the VPC, EKS cluster, node group, IAM roles, and security groups.

### 4. Configure kubectl

After Terraform completes, update your kubeconfig:

```sh
aws eks --region <region> update-kubeconfig --name <cluster_name>
```

Replace `<region>` and `<cluster_name>` with the values from Terraform outputs.

### 5. Deploy Kubernetes Manifests

Apply the Kubernetes manifests to set up dynamic provisioning and a sample workload:

```sh
kubectl apply -f KS8-manfifests/storage-class.yaml
kubectl apply -f KS8-manfifests/persistent-volume-claim.yaml
kubectl apply -f KS8-manfifests/service.yaml
kubectl apply -f KS8-manfifests/statefulset.yaml
```

---

## File Descriptions

- **iam.tf**: IAM roles and policies for EKS nodes and EBS CSI driver.
- **main.tf**: Main Terraform configuration for EKS cluster and node group.
- **outputs.tf**: Outputs such as cluster name, endpoint, and kubeconfig command.
- **providers.tf**: AWS and Kubernetes provider configuration.
- **security-group.tf**: Security groups for EKS cluster and nodes.
- **variables.tf**: Input variables for customizing the deployment.
- **versions.tf**: Terraform and provider version constraints.
- **vpc.tf**: VPC, subnets, and networking resources.
- **KS8-manfifests/**: Kubernetes manifests for storage and workloads:
  - `storage-class.yaml`: StorageClass for dynamic EBS provisioning.
  - `persistent-volume-claim.yaml`: PVC requesting storage from the StorageClass.
  - `service.yaml`: Headless service for StatefulSet.
  - `statefulset.yaml`: Example StatefulSet using the PVC.

---

## Outputs

After running Terraform, you will get:

- EKS cluster name and endpoint
- VPC and subnet IDs
- IAM role ARNs
- Command to configure kubectl

---

## Cleanup

To destroy all resources created by Terraform:

```sh
terraform destroy
```

---

---

## Features

- Automated VPC and EKS cluster provisioning using Terraform
- Secure IAM roles and policies for EKS and EBS CSI driver
- Dynamic EBS volume provisioning via Kubernetes StorageClass
- Example StatefulSet and Service using dynamically provisioned storage

---


## Testing the EBS Persistent Volume

It is crucial to verify that the dynamically provisioned EBS volume is functioning as expected. After deploying the manifests, you should:

1. **Check PVC and PV Status:**
   - Ensure the PersistentVolumeClaim (PVC) is bound to a PersistentVolume (PV):
     ```sh
     kubectl get pvc
     kubectl get pv
     ```
   - The status should be `Bound`.

2. **Validate Pod Storage Access:**
   - Exec into one of the pods in the StatefulSet and write data to the mounted volume:
     ```sh
     kubectl exec -it <pod-name> -- /bin/sh
     echo "hello world" > /data/testfile
     cat /data/testfile
     ```
   - The file should be readable and persistent.

3. **Test Data Persistence:**
   - Delete the pod and ensure the data remains after the pod is recreated:
     ```sh
     kubectl delete pod <pod-name>
     # Wait for the pod to restart, then exec again and check the file
     kubectl exec -it <new-pod-name> -- cat /data/testfile
     ```
   - The file should still exist, confirming EBS persistence.

> **Note:** These steps help ensure your EBS-backed storage is correctly provisioned and persistent across pod restarts, which is essential for stateful workloads.

---

## References

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- [AWS EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

---



# ---------------------------------------------------------------------------------------------------------------------
# Terraform Outputs
# ---------------------------------------------------------------------------------------------------------------------

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

# AWS Region
output "region" {
  description = "AWS region where the cluster is deployed"
  value       = var.region
}

# Networking Outputs
output "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# IAM Outputs
output "node_group_iam_role_name" {
  description = "IAM role name for EKS managed node group"
  value       = module.eks.eks_managed_node_groups["default_node_group"].iam_role_name
}

# Utility Outputs
output "configure_kubectl" {
  description = "Command to configure kubectl to connect to the EKS cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}
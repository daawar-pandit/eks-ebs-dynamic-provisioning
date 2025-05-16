# ---------------------------------------------------------------------------------------------------------------------
# AWS and Regional Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Cluster Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "Daawar-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

# ---------------------------------------------------------------------------------------------------------------------
# Networking Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ---------------------------------------------------------------------------------------------------------------------
# Node Group Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "instance_types" {
  description = "Instance types for the EKS node group"
  type        = list(string)
  default     = ["t2.medium"]
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 5
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 3
}

# ---------------------------------------------------------------------------------------------------------------------
# Tagging Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "EKS-Cluster"
  }
}
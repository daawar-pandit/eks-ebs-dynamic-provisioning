# ---------------------------------------------------------------------------------------------------------------------
# EKS Cluster Configuration
# ---------------------------------------------------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable IRSA - this is crucial for EBS CSI driver and other add-ons to work correctly
  enable_irsa = true

  # Endpoint access configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # EKS Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }
  
  # EKS Managed Node Group(s) configuration
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = var.instance_types
    
    attach_cluster_primary_security_group = true
    
    # Launch template configuration
    use_custom_launch_template = false
    create_iam_role            = true
    
    # IAM roles
    iam_role_additional_policies = {
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    
    # Security groups
    vpc_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }

  eks_managed_node_groups = {
    default_node_group = {
      name = "managed-node-group"

      # Scaling configuration
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Monitoring
      enable_monitoring = true
      
      # Node configuration
      capacity_type  = "ON_DEMAND"
      
      tags = var.tags
    }
  }

  # aws-auth configmap for RBAC
  manage_aws_auth_configmap = true

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Cluster Autoscaler Configuration
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.cluster_name}-cluster-autoscaler"
  description = "IAM policy for Kubernetes Cluster Autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = module.eks.eks_managed_node_groups["default_node_group"].iam_role_name
}
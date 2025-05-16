# ---------------------------------------------------------------------------------------------------------------------
# IAM Roles and Policies for EKS
# ---------------------------------------------------------------------------------------------------------------------

# IAM policy for EBS volume management
resource "aws_iam_policy" "eks_ebs_csi_policy" {
  name        = "${var.cluster_name}-AmazonEBSCSIDriverPolicy"
  description = "Policy to allow EKS nodes to manage EBS volumes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeInstances",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:ModifyVolume"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = [
          "arn:aws:ec2:*:*:volume/*",
          "arn:aws:ec2:*:*:snapshot/*"
        ]
        Condition = {
          StringEquals = {
            "ec2:CreateAction" = [
              "CreateVolume",
              "CreateSnapshot"
            ]
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach the EBS CSI policy to the node group role
resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy_attachment" {
  policy_arn = aws_iam_policy.eks_ebs_csi_policy.arn
  role       = module.eks.eks_managed_node_groups["default_node_group"].iam_role_name
}
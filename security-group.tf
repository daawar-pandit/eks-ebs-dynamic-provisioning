# ---------------------------------------------------------------------------------------------------------------------
# Security Groups for EKS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "eks_node_group_sg" {
  name        = "${var.cluster_name}-node-group-sg"
  description = "Security group for EKS managed node group"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-node-group-sg"
    }
  )
}

# Egress rules - allow all outbound traffic
resource "aws_security_group_rule" "node_egress_all" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
}

# Ingress rule - allow intra-VPC traffic
resource "aws_security_group_rule" "node_ingress_vpc" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  description       = "Allow all inbound traffic from within VPC"
}

# Optional: Security group rule to allow SSH access
# Note: In production, consider restricting to specific IPs or using AWS Systems Manager Session Manager instead
resource "aws_security_group_rule" "node_ssh_access" {
  security_group_id = aws_security_group.eks_node_group_sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Consider restricting this to specific IPs in production
  description       = "Allow SSH access to the nodes"
}
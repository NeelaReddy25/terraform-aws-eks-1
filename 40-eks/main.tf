resource "aws_key_pair" "eks" {
    key_name = "eksctl"
    #you can paste the public key directly like this
    #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1lcda5ldcwYM789a44yA/6LCIZM0igdUIihN8vWHIi Neela Reddy@neela"
    public_key = file("~/.ssh/eksctl.pub")
    # ~means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = "local.vpc_id"
  subnet_ids               = split(",", local.private_subnet_ids)
  control_plane_subnet_ids = split(",", local.private_subnet_ids)

  create_cluster_security_group = false
  cluster_security_group_id = local.cluster_sg_id

  create_node_security_group = false
  node_security_group_id = local.node_sg_id

  # the user which you have used to create cluster will get admin access
  enable_cluster_creator_admin_permissions = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size     = 2
    #   max_size     = 10
    #   desired_size = 2
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   #EKS takes aws linux 2 as it's os to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size     = 2
      max_size     = 10
      desired_size = 2
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
        #EKS takes aws linux 2 as it's os to the nodes
        key_name = aws_key_pair.eks.key_name
    }
}

  tags = var.common_tags
}
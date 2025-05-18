module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  providers = {
    aws  = aws
    time = time
    tls  = tls
  }

  cluster_name    = local.name
  cluster_version = "1.32"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      min_size       = 1
      max_size       = 2
      desired_size   = 2
    }
  }

  access_entries = {
    admins = {
      principal_arn     = module.iam_role_admins.iam_role_arn
      kubernetes_groups = ["admins"]

      policy_associations = {
        admins = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    readers = {
      principal_arn     = module.iam_role_readers.iam_role_arn

      policy_associations = {
        readers = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

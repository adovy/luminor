data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_secretsmanager_secret_version" "github_creds" {
  secret_id = aws_secretsmanager_secret.github_creds.id
}

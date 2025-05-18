module "iam_role_admins" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.55"

  providers = {
    aws = aws
  }

  trusted_role_arns = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"], local.eks_users.admins)
    
  create_role = true
  role_name   = "eks-admin"

  attach_admin_policy = true
}

module "iam_role_readers" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.55"

  providers = {
    aws = aws
  }

  trusted_role_arns = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"], local.eks_users.readers)

  create_role = true
  role_name   = "eks-read-only"

  attach_readonly_policy = true

  custom_role_policy_arns = [
    module.iam_policy_eks_api.arn
  ]
}

module "iam_policy_eks_api" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.55"

  providers = {
    aws = aws
  }

  name        = "EKSAccessAPI"
  description = "EKS API Access"
  policy      = data.aws_iam_policy_document.eks_api_access.json
}

data "aws_iam_policy_document" "eks_api_access" {
  statement {
    effect    = "Allow"
    actions   = ["eks:AccessKubernetesApi"]
    resources = ["*"]
  }
}

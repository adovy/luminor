module "irsa_atlantis" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.55"

  providers = {
    aws = aws
  }

  create_role = true
  role_name   = "${local.name}-eks-atlantis"

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  oidc_fully_qualified_subjects = ["system:serviceaccount:atlantis:atlantis"]

  provider_url = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

resource "helm_release" "atlantis" {
  name = "atlantis"

  chart      = "runatlantis"
  version    = "5.17.2"
  repository = "https://runatlantis.github.io/helm-charts"

  create_namespace = true
  namespace        = "atlantis"

  values = [
    templatefile(
      "${path.module}/config/atlantis.yaml",
      {
        name   = "atlantis"
        role   = module.irsa_atlantis.iam_role_arn
        token  = try(jsondecode(data.aws_secretsmanager_secret_version.github_creds)["GH_TOKEN"], "bar")
        secret = try(jsondecode(data.aws_secretsmanager_secret_version.github_creds)["GH_SECRET"], "baz")
        org    = "adovy"
      }
    )
  ]

  atomic            = true
  cleanup_on_fail   = true
  dependency_update = true
  force_update      = false
  max_history       = 5
  recreate_pods     = true
  replace           = false
  skip_crds         = false
  timeout           = 300
  wait              = true
  wait_for_jobs     = true
}

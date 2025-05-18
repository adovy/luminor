locals {
  default_tags = {
    env          = var.environment
    owner        = "dovydas"
    project      = "luminor"
    managed_by   = "terraform"
    git_location = "https://github.com/adovy/luminor"
  }

  name = "${var.environment}-dovydas"

  eks_users = {
    admins = [
      for user in var.eks_users.admins:
      "arn:aws:iam::835367859851:user/${user}"
    ]
    readers = [
      for user in var.eks_users.readers:
      "arn:aws:iam::835367859851:user/${user}"
    ]
  }
}

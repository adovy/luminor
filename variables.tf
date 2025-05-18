variable "environment" {
  type        = string
  description = "Environment name"
}

variable "eks_users" {
  type = object({
    admins  = set(string)
    readers = set(string)
  })
}

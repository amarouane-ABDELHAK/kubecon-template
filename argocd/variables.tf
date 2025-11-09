variable "argocd_applications" {
  type = list(object({
    app_name        = string
    project_name    = string
    repo_url        = string
    target_path     = string
    target_branch   = string
    override_values = optional(map(string))
    private         = optional(bool)
    application_namespace = optional(string)
  }))
  description = "List of ArgoCD applications to create"
}







variable "argocd_password" {
  type = string
}

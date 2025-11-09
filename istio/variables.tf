variable "istio_version" {
  description = "Version of Istio to install"
  type        = string
  default     = "1.25.2"
}

variable "istio_namespace" {
  description = "Namespace for Istio installation"
  type        = string
  default     = "istio-system"
}

variable "helm_repo_url" {
  description = "Istio Helm repository URL"
  type        = string
  default     = "https://istio-release.storage.googleapis.com/charts"
}

variable "istio_release_branch" {
  description = "Istio release branch for addon manifests"
  type        = string
  default     = "release-1.25"
}

variable "domain_name" {
  type = string

}

variable "namespaces" {
  type = list(string)
  default = ["ecommerce", "argocd"]
}


variable "ssl_private_key_path" {
  type        = string
  description = "certificate private key path"
}
variable "ssl_certificate_path" {
  type        = string
  description = "certificate path"
}

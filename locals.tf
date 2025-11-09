locals {
  ssl_certificate_path = var.ssl_certificate_path == null ?  "${path.root}/certs/localhost.local.crt" : var.ssl_certificate_path
  ssl_private_key_path = var.ssl_private_key_path == null ?  "${path.root}/certs/localhost.local.key" : var.ssl_private_key_path

  argocd_applications = [
    {
      app_name      = "green-app"
      project_name  = null
      repo_url      = "https://github.com/rslim087a/istio-service-mesh-kubernetes-kiali-grafana.git"
      target_path   = "microservices"
      target_branch = "main"
      application_namespace = "ecommerce"
      override_values = {}
    }
  ]
}

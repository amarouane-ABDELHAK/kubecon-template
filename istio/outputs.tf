output "istio_namespace" {
  description = "The namespace where Istio is installed"
  value       = kubernetes_namespace.istio_system.metadata[0].name
}

output "istio_version" {
  description = "The version of Istio installed"
  value       = var.istio_version
}

output "istio_base_status" {
  description = "Status of istio-base Helm release"
  value       = helm_release.istio_base.status
}

output "istiod_status" {
  description = "Status of istiod Helm release"
  value       = helm_release.istiod.status
}

output "istio_ingress_status" {
  description = "Status of istio-ingress Helm release"
  value       = helm_release.istio_ingress.status
}


output "addons_deployed" {
  description = "List of Istio addons deployed"
  value       = ["prometheus", "grafana", "kiali", "jaeger"]
}

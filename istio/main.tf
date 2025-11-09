terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Create istio-system namespace
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = var.istio_namespace
  }
}

# Install istio-base chart
resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = var.helm_repo_url
  chart      = "base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version


  depends_on = [kubernetes_namespace.istio_system]
}

# Install istiod chart
resource "helm_release" "istiod" {
  name       = "istiod"
  repository = var.helm_repo_url
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version
  wait       = true
  values = [yamlencode({
    sidecarInjectorWebhook = {
      neverInjectSelector = [
        # Match pods with job-name label (older K8s)
        {
          matchExpressions = [
            {
              key      = "job-name"
              operator = "Exists"
            }
          ]
        },
        # Match pods with batch.kubernetes.io/job-name label (newer K8s)
        {
          matchExpressions = [
            {
              key      = "batch.kubernetes.io/job-name"
              operator = "Exists"
            }
          ]
        }
      ]
    }
  })]
  depends_on = [helm_release.istio_base]
}

# Install istio-ingress gateway chart
resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = var.helm_repo_url
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  version    = var.istio_version

  depends_on = [helm_release.istiod]
}

# Download Istio addon manifests
resource "terraform_data" "download_istio_addons" {
  provisioner "local-exec" {
    # Todo make the addons env variables and loop through them here
    command = <<-EOT
      mkdir -p ${path.module}/istio-addons
      curl -L https://raw.githubusercontent.com/istio/istio/${var.istio_release_branch}/samples/addons/prometheus.yaml -o ${path.module}/istio-addons/prometheus.yaml
      curl -L https://raw.githubusercontent.com/istio/istio/${var.istio_release_branch}/samples/addons/grafana.yaml -o ${path.module}/istio-addons/grafana.yaml
      curl -L https://raw.githubusercontent.com/istio/istio/${var.istio_release_branch}/samples/addons/kiali.yaml -o ${path.module}/istio-addons/kiali.yaml
      curl -L https://raw.githubusercontent.com/istio/istio/${var.istio_release_branch}/samples/addons/jaeger.yaml -o ${path.module}/istio-addons/jaeger.yaml
    EOT
  }

  depends_on = [helm_release.istio_ingress]
}


resource "null_resource" "add-istio-addons" {
  depends_on = [terraform_data.download_istio_addons]

  provisioner "local-exec" {
    working_dir = "./istio"
    command     = "kubectl apply -f istio-addons/"
  }
}


# Create only the namespaces that don't exist
resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
    labels = {
      managed-by = "opentofu"
      "istio-injection" = "enabled"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels["created-at"]
    ]
  }
}


resource "null_resource" "setup-certificate-secrets" {

  depends_on = [helm_release.istio_ingress]

  triggers = {
    private_key_hash = sha256(file(var.ssl_private_key_path))
    certificate_hash = sha256(file(var.ssl_certificate_path))
  }

  provisioner "local-exec" {
    command     = <<-EOT
      kubectl create secret tls ingress-tls --key ${var.ssl_private_key_path} --cert ${var.ssl_certificate_path} -n ${var.istio_namespace}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}



resource "null_resource" "deploy-istio-gateway" {

  depends_on = [null_resource.setup-certificate-secrets]

  triggers = {
    gateway_hash = sha256(file("${path.module}/istio-gateway/gateway.yaml"))

  }

  provisioner "local-exec" {
    command     = <<-EOT
      kubectl apply -f ${path.module}/istio-gateway/
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

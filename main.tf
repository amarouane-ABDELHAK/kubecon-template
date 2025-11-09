
module "istio" {
  source = "./istio"
  domain_name = var.domain_name
  ssl_certificate_path = local.ssl_certificate_path
  ssl_private_key_path = local.ssl_private_key_path
}



module "argocd" {
  depends_on = [module.istio]
  source = "./argocd"
  argocd_applications = local.argocd_applications
  argocd_password = var.argocd_password

}

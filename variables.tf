variable "argocd_password" {
  default = "changethis"
  sensitive = true
}
variable "domain_name" {
  default = "localhost.local"
}
variable "ssl_certificate_path" {
  default = null
}
variable "ssl_private_key_path" {
  default = null
}

output "gw_ip" {
  value = module.gw.public_ip
}

output "app_url" {
  value = module.app.fqdn
}

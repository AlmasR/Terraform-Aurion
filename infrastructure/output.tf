output "ACCESS_KEY" {
  value = var.AWS_ACCESS_KEY
  sensitive = true
}

output "SECRET_KEY" {
  value = var.AWS_SECRET_KEY
  sensitive = true
}

output "MY_IP" {
  value = local.my_ip
}

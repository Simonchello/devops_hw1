output "http_port" {
  value = var.http_port
}

output "network_name" {
  value = docker_network.nginx.name
}

output "volume_name" {
  value = docker_volume.nginx_html.name
}

output "container_name" {
  value = docker_container.nginx.name
}

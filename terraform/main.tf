resource "docker_network" "nginx" {
  name = "primak-terraform-net"
}

resource "docker_volume" "nginx_html" {
  name = "primak-terraform-nginx-html"
}

resource "docker_image" "nginx" {
  name         = var.nginx_image
  keep_locally = true
}

resource "docker_container" "nginx" {
  name    = "primak-terraform-nginx"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.http_port
    ip       = "0.0.0.0"
  }

  networks_advanced {
    name = docker_network.nginx.name
  }

  # Docker populates a new named volume from the image's default HTML files.
  volumes {
    volume_name    = docker_volume.nginx_html.name
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }
}

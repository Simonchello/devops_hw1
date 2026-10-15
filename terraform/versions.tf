terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.6"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

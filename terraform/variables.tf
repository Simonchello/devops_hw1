variable "docker_host" {
  description = "Docker endpoint. Default: execute Terraform on the VM using sudo."
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "nginx_image" {
  description = "Nginx image shared by the independent Terraform container."
  type        = string
  default     = "nginx:1.28-alpine"
}

variable "http_port" {
  description = "Nonstandard published HTTP port for Terraform nginx."
  type        = number
  default     = 8081
  validation {
    condition     = var.http_port >= 1024 && var.http_port <= 65535 && floor(var.http_port) == var.http_port
    error_message = "Use an integer port between 1024 and 65535."
  }
}

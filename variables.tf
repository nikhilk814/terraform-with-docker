variable "docker_username" {
  type        = string
  description = "DockerHub username"
}

variable "docker_password" {
  type        = string
  description = "DockerHub password or access token"
  sensitive   = true
}


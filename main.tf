terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = "https://index.docker.io/v1/"
    username = var.docker_username
    password = var.docker_password
  }
}

# Pull nginx image
resource "docker_image" "hello-app" {
  name = "nikhilk814/hello-app:latest"
}

# Run nginx container
resource "docker_container" "hello-app_container" {
  name  = "hello-app_server"
  image = docker_image.hello-app.image_id

  ports {
    internal = 3000
    external = 3000
  }
}


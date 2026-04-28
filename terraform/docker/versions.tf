terraform {
  required_version = ">= 1.7.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  # Sử dụng socket của máy host (WSL) - container runner sẽ có /var/run/docker.sock được mount
}
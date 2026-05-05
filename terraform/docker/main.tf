# Tạo network riêng
resource "docker_network" "app_net" {
  name   = "cicd_network"
  driver = "bridge"
}

# Tạo các backend container
resource "docker_container" "backend" {
  count = var.backend_count
  name  = "backend-${count.index}"
  image = var.backend_image
  networks_advanced {
    name = docker_network.app_net.name
  }
}

# Tạo file cấu hình Nginx LB
data "template_file" "nginx_conf" {
  template = <<EOF
upstream backend_pool {
  least_conn;
  %{for i in range(var.backend_count)~}
  server backend-${i}:80;
  %{endfor~}
}
server {
  listen 80;
  location / {
    proxy_pass http://backend_pool;
    proxy_set_header Host $host;
  }
}
EOF
}

# Container Load Balancer
resource "docker_container" "lb" {
  name  = "load_balancer"
  image = var.lb_image
  ports {
    internal = 80
    external = var.nginx_port
  }
  networks_advanced {
    name = docker_network.app_net.name
  }
  upload {
    content = data.template_file.nginx_conf.rendered
    file    = "/etc/nginx/conf.d/default.conf"
  }
  restart = "always"
}

# Container cAdvisor để thu thập metrics Docker
resource "docker_container" "cadvisor" {
  name    = "cadvisor"
  image   = "gcr.io/cadvisor/cadvisor:latest"
  restart = "always"
  networks_advanced {
    name = docker_network.app_net.name
  }
  ports {
    internal = 8080
    external = 8080
  }
  volumes {
    container_path = "/rootfs"
    host_path      = "/"
    read_only      = true
  }
  volumes {
    container_path = "/var/run"
    host_path      = "/var/run"
  }
  volumes {
    container_path = "/sys"
    host_path      = "/sys"
    read_only      = true
  }
  volumes {
    container_path = "/var/lib/docker"
    host_path      = "/var/lib/docker"
    read_only      = true
  }
}

# Prometheus container
resource "docker_container" "prometheus" {
  name    = "prometheus"
  image   = "prom/prometheus:latest"
  restart = "always"
  networks_advanced {
    name = docker_network.app_net.name
  }
  ports {
    internal = 9090
    external = 9090
  }
  # Dùng upload thay vì volume mount
  upload {
    content = file("${path.module}/prometheus/prometheus.yml")
    file    = "/etc/prometheus/prometheus.yml"
  }
}

# Grafana container
resource "docker_container" "grafana" {
  name    = "grafana"
  image   = "grafana/grafana:latest"
  restart = "always"
  networks_advanced {
    name = docker_network.app_net.name
  }
  ports {
    internal = 3000
    external = 3000
  }
  upload {
    content = file("${path.module}/grafana/provisioning/datasources/prometheus.yml")
    file    = "/etc/grafana/provisioning/datasources/prometheus.yml"
  }
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=admin"
  ]
}

resource "docker_container" "bad_practice" {
  name  = "test-ssh-open"
  image = "nginx:alpine"
  ports {
    internal = 22
    external = 2222
    protocol = "tcp"
  }
}

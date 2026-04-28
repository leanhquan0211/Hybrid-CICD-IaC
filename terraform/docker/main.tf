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
  # Không map port ra ngoài, chỉ nội bộ
}

# Tạo file cấu hình Nginx LB
data "template_file" "nginx_conf" {
  template = <<EOF
upstream backend_pool {
  least_conn;
  %{ for i in range(var.backend_count) ~}
  server backend-${i}:80;
  %{ endfor ~}
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

# Tải image Nginx và khởi chạy LB, gắn config vào
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
  # Đảm bảo Nginx đọc lại config sau khi ghi
  restart = "always"
}
#Test n

# trigger CD pipeline

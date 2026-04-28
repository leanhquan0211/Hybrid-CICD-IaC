output "load_balancer_url" {
  description = "URL truy cập Load Balancer"
  value       = "http://localhost:${var.nginx_port}"
}   
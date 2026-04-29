output "load_balancer_url" {
  description = "URL truy cập Load Balancer"
  value       = "http://localhost:${var.nginx_port}"
}
output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://localhost:3000"
}   
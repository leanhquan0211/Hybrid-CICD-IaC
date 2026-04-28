variable "backend_count" {
  description = "Số lượng backend node"
  type        = number
  default     = 2
}

variable "nginx_port" {
  description = "Port public cho Load Balancer"
  type        = number
  default     = 80
}

# Biến cho image backend, load balancer
variable "backend_image" {
  description = "Image cho backend (dùng 1 web server đơn giản, ví dụ nginx:alpine)"
  type        = string
  default     = "nginx:alpine"
}

variable "lb_image" {
  description = "Image cho Load Balancer (Nginx custom config)"
  type        = string
  default     = "nginx:alpine"
}
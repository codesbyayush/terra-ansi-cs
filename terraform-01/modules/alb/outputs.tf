output "alb_dns_name" {
  value       = aws_lb.lb_main.dns_name
  description = "DNS name of the Application Load Balancer"
}


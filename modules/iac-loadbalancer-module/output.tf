# Output Load Balancer DNS Name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
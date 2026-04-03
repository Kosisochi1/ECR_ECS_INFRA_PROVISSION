output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn

}

output "name" {
  value = aws_lb.app_lb.dns_name
}
output "listener_http" {
  value = aws_lb_listener.http
}

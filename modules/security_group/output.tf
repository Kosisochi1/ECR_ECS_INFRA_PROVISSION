
output "alb_sg" {
  value = aws_security_group.alb_sg.id

}

output "ecs_sg" {
  value = aws_security_group.ecs.id

}


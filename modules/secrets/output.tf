output "secret_arn" {

  value = aws_secretsmanager_secret.secret_manager.arn
}

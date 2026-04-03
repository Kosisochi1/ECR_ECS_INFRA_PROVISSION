output "secret_arn" {

  value = aws_secretsmanager_secret.secret_manager.arn
}


output "secret_policy" {
  value = aws_iam_policy_attachment.secret_attachment.policy_arn

}

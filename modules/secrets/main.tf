
resource "aws_kms_key" "secret-KEY" {

  description             = "kms key for much_to_do app"
  deletion_window_in_days = 7
  enable_key_rotation     = true

}


resource "aws_kms_alias" "secret_alias" {
  name          = "alias/${var.app_name}-key"
  target_key_id = aws_kms_key.secret-KEY.key_id

}


resource "aws_secretsmanager_secret" "secret_manager" {
  name        = var.app_name
  description = "storing all secret keys for much_to_do app"
  kms_key_id  = aws_kms_key.secret-KEY.key_id

}


resource "aws_secretsmanager_secret_version" "demo_app_secret_key" {

  secret_id = aws_secretsmanager_secret.secret_manager.id
  secret_string = jsonencode({
    MONGO_URI = var.mongo_uri,
    LOG_LEVEL = "DEBUG",
    DB_NAME   = "much_todo_db",

    # Log format: "json" or "text"
    LOG_FORMAT = "json",

    # --- Testing ---
    INTEGRATION          = true,
    JWT_SECRET_KEY       = var.jwt_secret_key,
    JWT_EXPIRATION_HOURS = 72
  })



}


resource "aws_iam_policy" "secret_key_policy" {
  name = "${var.app_name}-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource = aws_secretsmanager_secret.secret_manager.arn
        }, {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",

        ]
        Resource = aws_kms_key.secret-KEY.arn

      }
    ]
  })

}


resource "aws_iam_policy_attachment" "secret_attachment" {
  name       = "${var.app_name}-secret-attachment"
  roles      = [var.task_role]
  policy_arn = aws_iam_policy.secret_key_policy.arn

}

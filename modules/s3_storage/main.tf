resource "aws_s3_bucket" "task_definition" {
  bucket = var.task_definition_bucket


}

resource "aws_s3_object" "task_def" {
  bucket       = aws_s3_bucket.task_definition.id
  key          = var.s3_key
  content      = var.local_content
  content_type = "application/json"

}

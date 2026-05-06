resource "random_id" "suffix_s3" {
  byte_length = 3
}


resource "aws_s3_bucket" "task_definition" {
  bucket = "var.task_definition_bucket-${random_id.suffix_s3.hex}"


}

resource "aws_s3_object" "task_def" {
  bucket       = aws_s3_bucket.task_definition.id
  key          = var.s3_key
  content      = var.local_content
  content_type = "application/json"

}

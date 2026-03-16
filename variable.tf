variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "much_to_do"

}

variable "port" {
  default = 4000
}
variable "cpu" {
  default = "256"
}
variable "memory" {
  default = "512"
}

variable "mongo_uri" {
  type      = string
  sensitive = true
}

variable "jwt_secret_key" {
  type      = string
  sensitive = true
}

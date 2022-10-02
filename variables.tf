variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "slack_app_token" {
  type = string
}
variable "slack_default_channel" {
  type = string
}
variable "function_name" {
  type    = string
  default = "sns_to_slack"
}
variable "project_name" {
  type    = string
  default = "sns_to_slack"
}
variable "docker_file" {
  type    = string
  default = "docker/lambda/Dockerfile"
}
variable "tag_deploy" {
  type    = string
  default = "deploy"
}
variable "branch-name_deploy" {
  type    = string
  default = "main"
}
variable "uri_repository" {
  type    = string
  default = "https://github.com/aokuyama/sns_to_slack-rs.git"
}

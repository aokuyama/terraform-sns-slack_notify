terraform {
  required_version = "~> 1.3.8"
}
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
data "aws_caller_identity" "self" {}
data "template_file" "buildspec" {
  template = file("./buildspec.yml")

  vars = {
    region             = var.region
    build_tag          = "rust-build-release"
    tag                = "${aws_ecr_repository.app.name}:${var.tag_deploy}"
    repository_tag     = "${aws_ecr_repository.app.repository_url}:${var.tag_deploy}"
    docker_path_deploy = "./deploy/lambda/Dockerfile"
    docker_path_build  = "./deploy/lambda/build.dockerfile"
  }
}

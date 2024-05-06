resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.prefix}-python-container-image"
}

locals {
  dockerfile_md5 = filemd5("${path.module}/Lambda.Dockerfile")
}

resource "docker_image" "ecr_image" {
  name = "${var.prefix}-ecr-image"

  triggers = {
    dockerfile_md5 = local.dockerfile_md5
  }
  build {
    context      = abspath("${path.module}/")
    force_remove = true
    dockerfile   = "Lambda.Dockerfile"
  }
}

resource "docker_tag" "ecr_tag" {
  source_image = docker_image.ecr_image.name
  target_image = "${aws_ecr_repository.ecr_repo.repository_url}:${local.dockerfile_md5}"
}

resource "docker_registry_image" "container_image" {
  name = docker_tag.ecr_tag.target_image
}

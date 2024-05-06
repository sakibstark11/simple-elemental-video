resource "aws_ecr_repository" "ecr_repo" {
  name = "${var.prefix}-python-container-image"
}

resource "docker_image" "ecr_image" {
  name = "${var.prefix}-ecr-image"

  triggers = {
    dockerfile_md5 = filemd5("${path.module}/Dockerfile")
  }
  build {
    context      = abspath("${path.module}/")
    force_remove = true
    dockerfile   = "Dockerfile"
  }
}

resource "docker_tag" "ecr_tag" {
  source_image = docker_image.ecr_image.name
  target_image = "${aws_ecr_repository.ecr_repo.repository_url}:${filemd5("${path.module}/Dockerfile")}"
}

resource "docker_registry_image" "container_image" {
  name = docker_tag.ecr_tag.target_image
}

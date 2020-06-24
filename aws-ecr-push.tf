locals {
  path = pathexpand(path.module)
}

# Calculate hash of the Docker image source contents
data "archive_file" "temp" {
  type       = "zip"
  source_dir = var.source_path
  output_path = format("%s/build/temp.zip", local.path)
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
    hash = data.archive_file.temp.output_base64sha256
  }

  provisioner "local-exec" {
    command     = format("%s/push.sh %s %s %s %s", local.path, var.source_path, var.repository_url, var.tag, var.iam_push_role)
    interpreter = ["bash", "-c"]
  }
}

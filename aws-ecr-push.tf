
# Calculate hash of the Docker image source contents
data "external" "hash" {
  program = ["bash", "-c", format("%s/hash.sh %s", path.module, var.source_path)]
}

# Build and push the Docker image whenever the hash changes
resource "null_resource" "push" {
  triggers = {
    hash = lookup(data.external.hash.result, "hash")
  }

  provisioner "local-exec" {
    command     = format("%s/push.sh %s %s %s %s", path.module, var.source_path, var.repository_url, var.tag, var.iam_push_role)
    interpreter = ["bash", "-c"]
  }
}

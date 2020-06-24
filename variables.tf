variable "iam_push_role" {
  type        = string
  description = "IAM role for pushing to ECR"
}

variable "repository_url" {
  type        = string
  description = "Repository URL"
}

variable "tag" {
  type        = string
  description = "Tag for docker image"
}

variable "source_path" {
  type        = string
  description = "File pathway to docker source"
}

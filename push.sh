#!/bin/bash
# $ ./push.sh . 123456789012.dkr.ecr.us-west-1.amazonaws.com/hello-world {tag} {iam_push_role|optional}

set -e

source_path="$1"
repository_url="$2"
tag="${3:-latest}"
temp_role=$4

region="$(echo "$repository_url" | cut -d. -f4)"
image_name="$(echo "$repository_url" | cut -d/ -f2)"

# build docker image
(cd "$source_path" && docker build -t "$image_name" .)

# sts to push account
if [ ! -z "${temp_role}" ]; then
    TEMP_ROLE=$(aws sts assume-role --role-arn ${temp_role} --role-session-name docker_push)
    export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
    export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
    export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
    echo ${AWS_SESSION_TOKEN}
fi

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $repository_url
docker tag "$image_name" "$repository_url":"$tag"
docker tag "$image_name" "$repository_url":latest
docker push "$repository_url":"$tag"
docker push "$repository_url":latest

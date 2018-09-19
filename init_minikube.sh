#!/bin/bash

export USER_ACCOUNT="${DOCKER_USERNAME}"
export SYSTEM_INSTALL_FLAGS="--node-port"

docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

fats_delete_image() {
  IFS=':' read -r -a image <<< "$1"
  repo=${image[0]}
  tag=${image[1]}

  echo "Delete image ${repo}:${tag}"
  TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token`
  curl "https://hub.docker.com/v2/repositories/${repo}/tags/${tag}/" -X DELETE -H "Authorization: JWT ${TOKEN}"
}

fats_create_push_credentials() {
  namespace="$1"

  echo "Create auth secret"
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: push-credentials
  namespace: $(echo -n "$namespace")
  annotations:
    build.knative.dev/docker-0: https://index.docker.io/v1/
type: kubernetes.io/basic-auth
data:
  username: $(echo -n "$DOCKER_USERNAME" | openssl base64 -a -A)
  password: $(echo -n "$DOCKER_PASSWORD" | openssl base64 -a -A)
EOF
}

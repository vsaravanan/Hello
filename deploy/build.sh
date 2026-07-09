#!/bin/bash
# k8master-build-api.sh
# Runs entirely on k8master (invoked via: bash k8master-build-api.sh <image>)
# The repo is already synced by the host script before this runs.

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/common.sh"
source "$REMOTE_DIR/environment.sh"

log_step "Build jar with Maven"
cd /data/java/Hello
mvn clean package

log_step "Build image with Buildah"
cd /data/java/Hello
buildah bud -t "$API_IMAGE" -f deploy/Dockerfile .

log_step "Record current git commit as the deployment tag"
git rev-parse --short HEAD > /data/java/Hello/deploy/.current_tag_api
cat /data/java/Hello/deploy/.current_tag_api



log_step "Push image to registry"
buildah push --tls-verify=false \
    "${API_IMAGE}" "docker://${API_IMAGE}"

log_info "build-api complete on k8master. Image: $API_IMAGE"

#!/bin/bash
# k8master-build-api.sh
# Runs entirely on k8master (invoked via: bash k8master-build-api.sh <image>)
# The repo is already synced by the host script before this runs.

set -exuo pipefail

START_TIME=$(date +%s)

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"


log_step "check out source code from $project_path"
cd "$project_path"
echo `pwd`

git reset --hard
git fetch
git checkout
git pull
chmod +x  *.sh deploy/*.sh || true

mv "$deploy_path/.current_tag_ui" "$deploy_path/.previous_tag_ui"  || true


log_step "Build jar with Maven"
cd $project_path
mvn clean package

log_step "Build image with Buildah"
cd $project_path
buildah bud -t "$api_image" -f deploy/Dockerfile .

log_step "Record current git commit as the deployment tag"
git rev-parse --short HEAD > $deploy_path/.current_tag_api
cat $deploy_path/.current_tag_api



log_step "Push image to registry"
buildah push --tls-verify=false \
    "${api_image}" "docker://${api_image}"

kubectl delete pod -l app=$module

log_info "build-api complete on $HOST. Image: $api_image"

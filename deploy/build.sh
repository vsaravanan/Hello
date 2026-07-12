#!/bin/bash
# k8master-build-api.sh
# Runs entirely on k8master (invoked via: bash k8master-build-api.sh <image>)
# The repo is already synced by the host script before this runs.

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

logfile=$(get_caller_script)
start_log_file $logfile

mylog "check status of registry and hello"
kubectl get all -A | grep -E "registry|hello" || true

mylog "docker images"
buildah images

mylog "check out source code from $project_path"
cd "$project_path"

checkout

mylog "Build jar with Maven"
cd $project_path
mvn clean package

mylog "Build image with Buildah"
cd $project_path
mylog "🚀 buildah building latest image ..."
buildah bud -t "$api_image" -f deploy/Dockerfile .

mylog "Record current git commit as the deployment tag"
git rev-parse --short HEAD > "$deploy_path/.current_tag"
cat "$deploy_path/.current_tag"


mylog "buildah push image to registry "
buildah push --tls-verify=false \
    "${api_image}" "$registry_url/${api_image}"


if image_exists "$api_image"; then
    mylog "📤 Rename latest image with timestamp..."
    newname=$(renameWithTimestamp "$api_image")

    buildah tag "$api_image" "$newname"
else
    mylog "no latest image found"
fi

log_info "Deleting pod for $module"
kubectl delete pod -l app=$module


mylog "Roll out latest API image"
kubectl set image deployment/$module $module="$api_image"

mylog "Wait for rollout to finish"
kubectl rollout status deployment/$module


mylog "check status of registry and hello"
kubectl get all -A | grep -E "registry|hello" || true

mylog "check status of Evicted and Error"
kubectl get all -A | grep -E "Evicted|Error" || true

mylog "buildah images"
buildah images

log_info "build complete on ${HOST}. Image: $api_image"

log_time
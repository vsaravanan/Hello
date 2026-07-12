#!/bin/bash
# k8master-build-api.sh
# Runs entirely on k8master (invoked via: bash k8master-build-api.sh <image>)
# The repo is already synced by the host script before this runs.

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

logfile=$(get_caller_script)
start_log_file $logfile

check_status

mylog "check out source code from $project_path"
cd "$project_path"

checkout

mylog "Build jar with Maven"
cd $project_path
mvn clean package

mylog "Build image with Buildah"
cd $project_path
mylog "🚀 buildah building latest image ..."
# buildah bud -t hello-api:latest -f deploy/Dockerfile .
buildah bud -t "$myimage" -f deploy/Dockerfile .

mylog "Record current git commit as the deployment tag"
git rev-parse --short HEAD > "$deploy_path/.current_tag"
cat "$deploy_path/.current_tag"


mylog "buildah push image to registry "
#  buildah push --tls-verify=false hello-api:latest docker://k8master:5000/hello-api:latest

buildah push --tls-verify=false \
    "${myimage}" "docker://${registry_url}/${myimage}"


if image_exists "$myimage"; then
    mylog "📤 Rename latest image with timestamp..."
    newname=$(renameWithTimestamp "$myimage")

    buildah tag "$myimage" "$newname"
else
    mylog "no latest image found"
fi

kubectl scale deployment $module --replicas=0

log_info "Deleting pod for $module"
kubectl delete pod -l app=$module || true


mylog "Roll out latest API image"
kubectl set image deployment/$module $module="$registry_url/${myimage}"

kubectl scale deployment $module --replicas=1

mylog "Wait for rollout to finish"
kubectl rollout status deployment/$module


check_status

mylog "check status of Evicted and Error"
kubectl get all -A | grep -E "Evicted|Error" || true

log_info "build complete on ${HOST}. Image: $myimage"

log_time
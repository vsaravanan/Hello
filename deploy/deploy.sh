#!/bin/bash
# k8master-deploy-api.sh
# Runs entirely on k8master (invoked via: bash k8master-deploy-api.sh <image>)

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

logfile=$(get_caller_script)
start_log_file $logfile

# kubectl delete deployment $module --ignore-not-found
# kubectl delete svc $service --ignore-not-found
# kubectl delete pod -l app=$module

mylog "Save current image as previous tag (for rollback)"
kubectl get deployment $module -o jsonpath='{.spec.template.spec.containers[0].image}' > $deploy_path/.previous_tag_api 2>/dev/null || echo "none" > $deploy_path/.previous_tag_api
cat $deploy_path/.previous_tag_api

# mylog "Apply $module manifest"
# kubectl apply -f $deploy_path/$module.yaml

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

log_info "deploy $module complete on $HOST."

log_time
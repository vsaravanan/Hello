#!/bin/bash
# k8master-deploy-api.sh
# Runs entirely on k8master (invoked via: bash k8master-deploy-api.sh <image>)

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

kubectl delete deployment $module --ignore-not-found
kubectl delete svc $service --ignore-not-found
kubectl delete pod -l app=$module

log_step "Save current image as previous tag (for rollback)"
kubectl get deployment $module -o jsonpath='{.spec.template.spec.containers[0].image}' > $deploy_path/.previous_tag_api 2>/dev/null || echo "none" > $deploy_path/.previous_tag_api
cat $deploy_path/.previous_tag_api

log_step "Apply $module manifest"
kubectl apply -f $deploy_path/$module.yaml

log_step "Roll out latest API image"
kubectl set image deployment/$module $module="$api_image"

log_step "Wait for rollout to finish"
kubectl rollout status deployment/$module

log_info "deploy-api complete on $HOST."

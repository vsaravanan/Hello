#!/bin/bash
# k8master-deploy-api.sh
# Runs entirely on k8master (invoked via: bash k8master-deploy-api.sh <image>)

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/common.sh"
source "$REMOTE_DIR/environment.sh"

log_step "Save current image as previous tag (for rollback)"
kubectl get deployment hello-api -o jsonpath='{.spec.template.spec.containers[0].image}' > /data/java/Hello/deploy/.previous_tag_api 2>/dev/null || echo "none" > /data/java/Hello/deploy/.previous_tag_api
cat /data/java/Hello/deploy/.previous_tag_api

log_step "Apply hello-api manifest"
kubectl apply -f /data/java/Hello/deploy/hello-api.yaml

log_step "Roll out latest API image"
kubectl set image deployment/hello-api hello-api="$API_IMAGE"

log_step "Wait for rollout to finish"
kubectl rollout status deployment/hello-api

log_info "deploy-api complete on k8master."

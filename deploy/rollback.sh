#!/bin/bash
# k8master-rollback-api.sh
# Runs entirely on k8master (invoked via: bash k8master-rollback-api.sh)

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"


log_step "Read previous image tag"
PREVIOUS_TAG="$(cat /data/java/Hello/deploy/.previous_tag_api)"
echo "$PREVIOUS_TAG"

if [ "$PREVIOUS_TAG" = "none" ]; then
    log_error "No previous image recorded, cannot roll back."
    exit 1
fi

log_step "Roll back hello-api deployment"
kubectl set image deployment/hello-api hello-api="$PREVIOUS_TAG"

log_step "Wait for rollback rollout to finish"
kubectl rollout status deployment/hello-api

log_info "rollback-api complete on k8master."

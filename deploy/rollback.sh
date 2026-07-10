#!/bin/bash
# k8master-rollback-api.sh
# Runs entirely on k8master (invoked via: bash k8master-rollback-api.sh)

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"


log_step "Read previous image tag"
PREVIOUS_TAG="$(cat $deploy_path/.previous_tag_api)"
echo "$previous_tag"

if [ "$previous_tag" = "none" ]; then
    log_error "No previous image recorded, cannot roll back."
    exit 1
fi

log_step "Roll back $module deployment"
kubectl set image deployment/$module $module="$previous_tag"

log_step "Wait for rollback rollout to finish"
kubectl rollout status deployment/$module

log_info "rollback-api complete on $HOST."

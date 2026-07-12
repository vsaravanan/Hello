#!/bin/bash
# k8master-cleanup-api.sh
# Runs entirely on k8master (invoked via: bash k8master-cleanup-api.sh)
# Also sweeps stopped Buildah containers, which aren't api/ui specific.

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"


mylog "Remove dangling (untagged) Buildah images"
buildah images --filter dangling=true --format '{{.ID}}' | xargs -r buildah rmi

mylog "Remove stopped Buildah containers"
buildah rm --all

mylog "Remove leftover $module validation check pod"
kubectl delete pod curl-api-check --ignore-not-found

log_info "cleanup-api complete on k8master."

#!/bin/bash
# k8master-validate-api.sh
# Runs entirely on k8master (invoked via: bash k8master-validate-api.sh)

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"


log_step "Check hello-api pod status"
kubectl get pods -l app=hello-api

log_step "Wait for hello-api pod to be Ready"
kubectl wait --for=condition=Ready pod -l app=hello-api --timeout=60s

log_step "Curl hello-api health endpoint"
kubectl run curl-api-check --rm -i --restart=Never --image=curlimages/curl -- curl -sf http://hello-api-svc:8080/actuator/health

log_info "validate-api complete on k8master."

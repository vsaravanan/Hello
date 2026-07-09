#!/bin/bash
# common.sh
# Logging helpers for the host-side scripts (the ones you run locally,
# which then ssh into k8master). Remote logging lives in
# remote/k8master-common.sh, since that's a separate file that runs
# entirely on k8master.

log_info() {
    echo "[INFO]  $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_warn() {
    echo "[WARN]  $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_step() {
    echo ""
    echo "========================================"
    echo "STEP: $1"
    echo "========================================"
}

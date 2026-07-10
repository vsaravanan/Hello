#!/bin/bash
# common.sh
# Logging helpers for the host-side scripts (the ones you run locally,
# which then ssh into k8master). Remote logging lives in
# remote/k8master-common.sh, since that's a separate file that runs
# entirely on k8master.

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
fail() { printf '\n\033[1;31mFAILED: %s\033[0m\n' "$1" >&2; exit 1; }

log_info() {
  set +x
  printf '\n\033[1;36m==> %s\033[0m\n' " $1"
  set -x
}

log_warn() {
    echo "[WARN]  $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_step() {
    set +x
    echo ""
    echo "========================================"
    # echo "STEP: $1"
    printf '\n\033[1;36m==> %s\033[0m\n' "$1"
    echo "========================================"
    set -x
}


log_time() {
    local start_time=$1
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    log_info "✅ Done! Total time: ${minutes}m ${seconds}s"

}

source "$remote_dir/environment.sh"

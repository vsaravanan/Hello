#!/bin/bash

set -euo pipefail

# Variables
# PROJECT_DIR=/data/java/Hello
# BUILD_DIR=/data/java/k8java
# REGISTRY="k8master:5000"
# IMAGE_NAME="hello-api:latest"
# FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"

copy_dir() {
    local Origin="$1"
    local Project="$2"
    local gzfile="$Origin/${Project}.tar.gz"

    cd "$Origin"

    rm -f $gzfile 

    log "Copying $gzfile to ${NODE}..."

    tar --exclude='target' --exclude='.idea' -czf $gzfile -C $Origin $Project

    lxc exec ${NODE} -- bash -c " rm -rf $Origin/${Project} $gzfile "
    lxc exec ${NODE} -- bash -c " mkdir -p $Origin "
    lxc file push $gzfile ${NODE}$gzfile
    lxc exec ${NODE} -- bash -c " tar -xzf $gzfile  -C '$Origin' && rm -f '${gzfile}'"
    rm -f "${gzfile}" 

}

ORIGIN_DIR="${ORIGIN_DIR:-/data/java}"
PROJECT_DIR="${PROJECT_DIR:-/data/java/Hello}"
BUILD_DIR="${BUILD_DIR:-/data/java/Hello/deploy}"
REGISTRY="${REGISTRY:-k8master:5000}"
IMAGE_REPO="${IMAGE_REPO:-hello-api}"
NODE="${NODE:-k8master}"


log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }
fail() { printf '\n\033[1;31mFAILED: %s\033[0m\n' "$1" >&2; exit 1; }
 
start_time=$(date +%s)

log "Starting buildah deployment $start_time"

log "Preflight checks"
 
command -v lxc  >/dev/null || fail "lxc not found on PATH"
command -v mvn  >/dev/null || fail "mvn not found on PATH"

[[ -d "${PROJECT_DIR}" ]]            || fail "PROJECT_DIR does not exist: ${PROJECT_DIR}"
[[ -f "${BUILD_DIR}/Dockerfile" ]]   || fail "Dockerfile not found: ${BUILD_DIR}/Dockerfile"

lxc info "${NODE}" &>/dev/null       || fail "LXD container '${NODE}' not found/running"
lxc exec "${NODE}" -- buildah >/dev/null || fail "buildah not found inside ${NODE}"

cd "${PROJECT_DIR}"


git -C "${PROJECT_DIR}" pull



# Prepare k8master directories
lxc exec "${NODE}" -- mkdir -p "${PROJECT_DIR}" 

# Copy source code, Dockerfile, and build script to k8master
log "Copying files to ${NODE}..."


copy_dir "${ORIGIN_DIR}" Hello
# lxc file push -r /data/java/Hello k8master/data/java
# lxc file push /data/java/Hello.tar.gz k8master/data/java/Hello.tar.gz


lxc exec "${NODE}" -- git config --global --add safe.directory "${PROJECT_DIR}"
lxc exec "${NODE}" -- git -C "${PROJECT_DIR}" reset --hard
lxc exec "${NODE}" -- git -C "${PROJECT_DIR}" pull


for arg in "$@"; do
    case "$arg" in
        registry)
            log "Applying registry..."
            # lxc exec k8master -- kubectl apply -f /data/java/Hello/deploy/registry.yaml
            lxc exec "${NODE}" -- kubectl apply -f "${BUILD_DIR}/registry.yaml"
            sleep 5
            ;;
        deploy-hello)
            log "Applying deploy-hello..."

            # + lxc exec k8master -- kubectl apply -f /data/java/Hello/deploy/deploy-hello.yaml

            lxc exec "${NODE}" -- kubectl apply -f "${BUILD_DIR}/deploy-hello.yaml"

            log "Waiting for deployment..."

            # deployment.apps/hello-api created
            # service/hello-api-svc created
            # + lxc exec k8master -- kubectl rollout status deployment/hello-api --timeout=120s

            lxc exec "${NODE}" --  kubectl rollout status deployment/hello-api --timeout=120s

            log "Deployment is ready."
            ;;
        *)
            log "Unknown argument: $arg"
            ;;
    esac
done






# Execute build script on ${NODE}
log "Executing build on ${NODE}..."
# + lxc exec k8master -- bash /data/java/Hello/deploy/k8master-build.sh
lxc exec "${NODE}" -- bash "${BUILD_DIR}/k8master-build.sh"

log "Image built and pushed"

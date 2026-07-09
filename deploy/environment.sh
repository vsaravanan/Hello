#!/bin/bash
# environment.sh (backend / hello-api)
# Sourced by every host-side script in this deploy/ folder.
# This file lives inside the Hello repo, so it's identical on the
# host and on k8master once git pull has synced them.

BACKEND_GIT_URL="https://github.com/vsaravanan/Hello.git"
BACKEND_DIR="/data/java/Hello"
API_IMAGE="k8master:5000/hello-api:latest"

HOST="k8master"

#!/bin/bash
# environment.sh (backend / $module)
# Sourced by every host-side script in this deploy/ folder.
# This file lives inside the Hello repo, so it's identical on the
# host and on k8master once git pull has synced them.

git_url="https://github.com/vsaravanan/Hello.git"
HOST="k8master"
module="hello-api"
service="$module-svc"
project_path="/data/java/Hello"
deploy_path="$project_path/deploy"
api_image="$HOST:5000/$module:latest"



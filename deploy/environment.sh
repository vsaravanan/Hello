#!/bin/bash
# environment.sh (backend / $module)
# Sourced by every host-side script in this deploy/ folder.
# This file lives inside the Hello repo, so it's identical on the
# host and on k8master once git pull has synced them.

git_url="https://github.com/vsaravanan/Hello.git"
module="hello-api"
service="hello-api-svc"
project_path="/data/java/Hello"
deploy_path="/data/java/Hello/deploy"
api_image="k8master:5000/hello-api:latest"

HOST="k8master"

set -exuo pipefail

# If no parameters, restart all
if [ $# -eq 0 ]; then
    echo "which app need to be restarted "
    exit 0
fi

module=$1
buildah push --tls-verify=false     $module:latest "docker://k8master:5000/$module:latest"
kubectl apply -f $module.yaml

kubectl apply -f /data/java/Hello/deploy/registry.yaml
  

kubectl apply -f /data/java/Hello/deploy/hello-api.yaml
  

kubectl apply -f /data/fe/hello-ui/deploy/hello-ui.yaml

kubectl scale deployment hello-api hello-ui  --replicas=0

kubectl get deploy,svc | grep -E "registry|hello-api|hello-ui" || true

kubectl scale deployment registry --replicas=1

kubectl rollout status deployment/registry --timeout=60s

# 2. Wait for registry to be ready
echo "⏳ Waiting for registry to be ready..."
kubectl wait --for=condition=available deployment/registry --timeout=60s
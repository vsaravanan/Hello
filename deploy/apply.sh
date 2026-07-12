
kubectl apply -f /data/java/Hello/deploy/registry.yaml
  

kubectl apply -f /data/java/Hello/deploy/hello-api.yaml
  

kubectl apply -f /data/fe/hello-ui/deploy/hello-ui.yaml

kubectl scale deployment hello-api hello-ui registry --replicas=0

kubectl get deploy,svc | grep -E "registry|hello-api|hello-ui" || true

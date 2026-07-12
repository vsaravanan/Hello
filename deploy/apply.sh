
kubectl apply -f /data/java/Hello/deploy0/registry.yaml
  

kubectl apply -f /data/java/Hello/deploy/hello-api.yaml
  

kubectl apply -f /data/fe/hello-ui/deploy/hello-ui.yaml

kubectl scale deployment hello-api hello-ui registry --replicas=0
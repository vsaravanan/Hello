kubectl create namespace redis

mkdir -p /data/redis
cd /data/redis

kubectl apply -f redis.yaml
kubectl apply -f redis-service.yaml
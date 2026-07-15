helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator --namespace datadog --create-namespace
kubectl create secret generic datadog-secret --from-literal api-key=cff5b1a2d1aaac00c29a4294e63a0915 -n datadog


helm upgrade datadog datadog/datadog-agent -f datadog-agent.yaml -n datadog

helm upgrade datadog datadog/datadog \
  --set datadog.apiKey=cff5b1a2d1aaac00c29a4294e63a0915 \
  --set datadog.clusterName=saravanjs \
  --set datadog.hostname=k8master \
  --set datadog.clusterAgent.enabled=true \
  --set datadog.clusterAgent.metricsProvider.enabled=true \
  -n datadog
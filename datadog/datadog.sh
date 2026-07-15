helm repo add datadog https://helm.datadoghq.com
helm install datadog-operator datadog/datadog-operator --namespace datadog --create-namespace

helm install datadog-operator datadog/datadog-operator \
  --set datadog.apiKey=cff5b1a2d1aaac00c29a4294e63a0915 \
  --set datadog.clusterName=saravanjs \
  --set datadog.hostname=k8master \
  --set datadog.clusterAgent.enabled=true \
  --set datadog.clusterAgent.metricsProvider.enabled=true \
  -n datadog --create-namespace

kubectl create secret generic datadog-secret --from-literal api-key=cff5b1a2d1aaac00c29a4294e63a0915 -n datadog

root@k8master:/data/java/Hello/datadog# helm install datadog-agent datadog/datadog -f datadog-agent.yaml -n datadog
Error: INSTALLATION FAILED: unable to continue with install: CustomResourceDefinition "datadogagentinternals.datadoghq.com" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "datadog-agent": current value is "datadog-operator"


helm install datadog-agent datadog/datadog -f datadog-agent.yaml -n datadog

helm upgrade datadog datadog/datadog-agent -f datadog-agent.yaml -n datadog

helm upgrade datadog datadog/datadog \
  --set datadog.apiKey=cff5b1a2d1aaac00c29a4294e63a0915 \
  --set datadog.clusterName=saravanjs \
  --set datadog.hostname=k8master \
  --set datadog.clusterAgent.enabled=true \
  --set datadog.clusterAgent.metricsProvider.enabled=true \
  -n datadog
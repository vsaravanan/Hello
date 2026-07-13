
==================== Step 1 Install Helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

==================== Step 2 Add Helm repositories

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm repo list

root@k8master:~# helm repo list
NAME                    URL
prometheus-community    https://prometheus-community.github.io/helm-charts
grafana                 https://grafana.github.io/helm-charts

==================== Step 3 Create namespace monitoring 

kubectl create namespace monitoring

root@k8master:~# kubectl create namespace monitoring
namespace/monitoring created

kubectl get ns

root@k8master:~# kubectl get ns
NAME              STATUS   AGE
default           Active   8d
kube-flannel      Active   8d
kube-node-lease   Active   8d
kube-public       Active   8d
kube-system       Active   8d
monitoring        Active   38s

==================== Step 4 Install kube-prometheus-stack

This chart installs

Prometheus
Grafana
Alertmanager
Node Exporter
kube-state-metrics


helm install monitoring \
    prometheus-community/kube-prometheus-stack \
    --namespace monitoring


root@k8master:~# helm install monitoring \
    prometheus-community/kube-prometheus-stack \
    --namespace monitoring
NAME: monitoring
LAST DEPLOYED: Sun Jul 12 19:14:24 2026
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

kubectl --namespace monitoring get pods -l "release=monitoring"

root@k8master:~# kubectl --namespace monitoring get pods -l "release=monitoring"
NAME                                                   READY   STATUS    RESTARTS   AGE
monitoring-kube-prometheus-operator-776b5c69df-zrfwk   1/1     Running   0          79s
monitoring-kube-state-metrics-7f57b7f795-2x2js         1/1     Running   0          79s
monitoring-prometheus-node-exporter-5sndq              1/1     Running   0          79s
monitoring-prometheus-node-exporter-v7hv2              1/1     Running   0          79s

kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
9g72ajBMDgEaJgr7giPNacE626Ve3aHis4V1CkE3

root@k8master:~# export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io        /instance=monitoring" -oname)
root@k8master:~# echo $POD_NAME
pod/monitoring-grafana-7d44dcc568-42ch6


root@k8master:~#   kubectl --namespace monitoring port-forward $POD_NAME 3000
Forwarding from 127.0.0.1:3000 -> 3000
Forwarding from [::1]:3000 -> 3000

root@k8master:~# kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo
9g72ajBMDgEaJgr7giPNacE626Ve3aHis4V1CkE3

==================== Step 5 Check installation

kubectl get pods -n monitoring

root@k8master:~# kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   0          10m
monitoring-grafana-7d44dcc568-42ch6                      3/3     Running   0          11m
monitoring-kube-prometheus-operator-776b5c69df-zrfwk     1/1     Running   0          11m
monitoring-kube-state-metrics-7f57b7f795-2x2js           1/1     Running   0          11m
monitoring-prometheus-node-exporter-5sndq                1/1     Running   0          11m
monitoring-prometheus-node-exporter-v7hv2                1/1     Running   0          11m
prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   0          10m

kubectl get svc -n monitoring

==================== Step 6 Check Services

root@k8master:~# kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   11m
monitoring-grafana                        ClusterIP   10.106.216.183   <none>        80/TCP                       12m
monitoring-kube-prometheus-alertmanager   ClusterIP   10.108.74.160    <none>        9093/TCP,8080/TCP            12m
monitoring-kube-prometheus-operator       ClusterIP   10.104.148.102   <none>        443/TCP                      12m
monitoring-kube-prometheus-prometheus     ClusterIP   10.107.74.169    <none>        9090/TCP,8080/TCP            12m
monitoring-kube-state-metrics             ClusterIP   10.99.127.153    <none>        8080/TCP                     12m
monitoring-prometheus-node-exporter       ClusterIP   10.110.219.89    <none>        9100/TCP                     12m
prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     11m

==================== Step 7 Change Grafana to NodePort

kubectl patch svc monitoring-grafana \
    -n monitoring \
    -p '{"spec":{"type":"NodePort"}}'

root@k8master:~# kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   19m
monitoring-grafana                        NodePort    10.106.216.183   <none>        80:30466/TCP                 20m
monitoring-kube-prometheus-alertmanager   ClusterIP   10.108.74.160    <none>        9093/TCP,8080/TCP            20m
monitoring-kube-prometheus-operator       ClusterIP   10.104.148.102   <none>        443/TCP                      20m
monitoring-kube-prometheus-prometheus     ClusterIP   10.107.74.169    <none>        9090/TCP,8080/TCP            20m
monitoring-kube-state-metrics             ClusterIP   10.99.127.153    <none>        8080/TCP                     20m
monitoring-prometheus-node-exporter       ClusterIP   10.110.219.89    <none>        9100/TCP                     20m
prometheus-operated                       ClusterIP   None             <none>        9090/TCP              

==================== Step 8 Access Grafana


root@k8master:~# curl -s 10.106.216.183
<a href="/login">Found</a>.

root@k8master:~# curl -s k8master:30466
<a href="/login">Found</a>.

PORT      STATE SERVICE
22/tcp    open  ssh
6443/tcp  open  sun-sr-https
8443/tcp  open  https-alt
30030/tcp open  unknown
30080/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 1.91 seconds
viswar@k8s:~$ curl -s k8master:30466
<a href="/login">Found</a>.

viswar@k8s:~$ lxc config device add k8master grafana proxy listen=tcp:0.0.0.0:30466 connect=tcp:192.168.100.10:30466
Device grafana added to k8master

==================== Step 9 Get Grafana password
kubectl get secret \
monitoring-grafana \
-n monitoring \
-o jsonpath="{.data.admin-password}" \
| base64 -d
9g72ajBMDgEaJgr7giPNacE626Ve3aHis4V1CkE3

==================== Step 10 Open Prometheus

kubectl patch svc monitoring-kube-prometheus-prometheus \
    -n monitoring \
    -p '{"spec":{"type":"NodePort"}}'


root@k8master:~# kubectl get svc -n monitoring
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                       
alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP    
monitoring-grafana                        NodePort    10.106.216.183   <none>        80:30466/TCP                  
monitoring-kube-prometheus-alertmanager   ClusterIP   10.108.74.160    <none>        9093/TCP,8080/TCP             
monitoring-kube-prometheus-operator       ClusterIP   10.104.148.102   <none>        443/TCP                       
monitoring-kube-prometheus-prometheus     NodePort    10.107.74.169    <none>        9090:31298/TCP,8080:32528/TCP 
monitoring-kube-state-metrics             ClusterIP   10.99.127.153    <none>        8080/TCP                      
monitoring-prometheus-node-exporter       ClusterIP   10.110.219.89    <none>        9100/TCP                      
prometheus-operated                       ClusterIP   None             <none>        9090/TCP                      



root@k8master:~#  curl -s k8master:31298
<a href="/query">Found</a>.

root@k8master:~#  curl -s 10.107.74.169:9090
<a href="/query">Found</a>.


lxc config device add k8master promo proxy listen=tcp:0.0.0.0:9090 connect=tcp:192.168.100.10:31298
Device promo added to k8master


viswar@k8s:~$ nmap localhost -p-
Starting Nmap 7.98 ( https://nmap.org ) at 2026-07-12 20:32 +0000
PORT      STATE SERVICE
22/tcp    open  ssh
6443/tcp  open  sun-sr-https
8443/tcp  open  https-alt
9090/tcp  open  zeus-admin
30030/tcp open  unknown
30080/tcp open  unknown
30466/tcp open  unknown

root@k8master:~# helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
monitoring      monitoring      1               2026-07-12 19:14:24.770598189 +0000 UTC deployed        kube-prometheus-stack-87.15.1   v0.92.1

root@k8master:~# kubectl top nodes
error: Metrics API not available

root@k8master:~# helm repo list
NAME                    URL
prometheus-community    https://prometheus-community.github.io/helm-charts
grafana                 https://grafana.github.io/helm-charts
root@k8master:~#
root@k8master:~#
root@k8master:~# helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
"metrics-server" has been added to your repositories
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "metrics-server" chart repository
...Successfully got an update from the "grafana" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
root@k8master:~# helm repo list
NAME                    URL
prometheus-community    https://prometheus-community.github.io/helm-charts
grafana                 https://grafana.github.io/helm-charts
metrics-server          https://kubernetes-sigs.github.io/metrics-server/
root@k8master:~# helm search repo metrics-server
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
metrics-server/metrics-server   3.13.1          0.8.1           Metrics Server is a scalable, efficient source ...
root@k8master:~#



root@k8master:~# helm uninstall metrics-server --namespace kube-system
release "metrics-server" uninstalled

root@k8master:~# helm install metrics-server \
    metrics-server/metrics-server \
    -n kube-system \
    --set args="{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP}"
NAME: metrics-server
LAST DEPLOYED: Sun Jul 12 20:57:39 2026
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
* Metrics Server                                                      *
***********************************************************************
  Chart version: 3.13.1
  App version:   0.8.1
  Image tag:     registry.k8s.io/metrics-server/metrics-server:v0.8.1
***********************************************************************

root@k8master:~# kubectl rollout status deployment/metrics-server -n kube-system
deployment "metrics-server" successfully rolled out

root@k8master:~# kubectl get pods -n kube-system
NAME                               READY   STATUS    RESTARTS      AGE
metrics-server-64c8677874-vtnlx    1/1     Running   0             2m5s

root@k8master:~# kubectl top nodes
NAME        CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
k8master    146m         7%       1921Mi          48%
k8worker1   104m         5%       1921Mi          48%

root@k8master:~# helm list -A
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
metrics-server  kube-system     1               2026-07-12 20:57:39.473595566 +0000 UTC deployed        metrics-server-3.13.1           0.8.1
monitoring      monitoring      1               2026-07-12 19:14:24.770598189 +0000 UTC deployed        kube-prometheus-stack-87.15.1   v0.92.1


root@k8master:~# helm repo list
NAME                    URL
prometheus-community    https://prometheus-community.github.io/helm-charts
grafana                 https://grafana.github.io/helm-charts
metrics-server          https://kubernetes-sigs.github.io/metrics-server/


root@k8master:~# kubectl get apiservice | grep metrics
v1beta1.metrics.k8s.io            kube-system/metrics-server   True        5m16s

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>

<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>


management.endpoints.web.exposure.include=health,info,prometheus
management.endpoint.health.show-details=always
management.prometheus.metrics.export.enabled=true

root@k8master:/data/java/Hello/deploy# kubectl port-forward svc/hello-api-svc 8080:80
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080

root@k8master:/data/java/Hello/deploy# curl  http://10.109.153.121/actuator/health
{"groups":["liveness","readiness"],"status":"UP"}root@k8master:/data/java/Hello/deploy#


root@k8master:/data/java/Hello/deploy# curl http://localhost:8080/actuator/health
{"groups":["liveness","readiness"],"status":"UP"}root@k8master:/data/java/Hello/deploy#

cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04 LTS"
Kernel: Linux 7.0.0-27-generic
hostname: k8s
Firmware Date: Fri 2006-12-01
uname -r
7.0.0-27-generic

viswar@k8s:~$ lxc --version
6.9

root@k8master:/data/java/Hello/deploy# kubectl version
Client Version: v1.33.13
Kustomize Version: v5.6.0
Server Version: v1.33.13



==================== Step 1 Install Helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

root@k8master:/data/java/Hello/deploy# helm version
version.BuildInfo{Version:"v4.2.3", GitCommit:"43e8b7feece8beb0fcba47059ec9b522fd929a64", GitTreeState:"clean", GoVersion:"go1.26.5", KubeClientVersion:"v1.36"}


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



kubectl --namespace monitoring get pods -l "release=monitoring"

root@k8master:~# kubectl --namespace monitoring get pods -l "release=monitoring"
NAME                                                   READY   STATUS    RESTARTS   AGE
monitoring-kube-prometheus-operator-776b5c69df-zrfwk   1/1     Running   0          79s
monitoring-kube-state-metrics-7f57b7f795-2x2js         1/1     Running   0          79s
monitoring-prometheus-node-exporter-5sndq              1/1     Running   0          79s
monitoring-prometheus-node-exporter-v7hv2              1/1     Running   0          79s



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

root@k8master:~# kubectl get svc -n kube-system
NAME                                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                        AGE
kube-dns                                             ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP         8d
metrics-server                                       ClusterIP   10.104.188.84   <none>        443/TCP                        119m
monitoring-kube-prometheus-coredns                   ClusterIP   None            <none>        9153/TCP                       3h42m
monitoring-kube-prometheus-kube-controller-manager   ClusterIP   None            <none>        10257/TCP                      3h42m
monitoring-kube-prometheus-kube-etcd                 ClusterIP   None            <none>        2381/TCP                       3h42m
monitoring-kube-prometheus-kube-proxy                ClusterIP   None            <none>        10249/TCP                      3h42m
monitoring-kube-prometheus-kube-scheduler            ClusterIP   None            <none>        10259/TCP                      3h42m
monitoring-kube-prometheus-kubelet                   ClusterIP   None            <none>        10250/TCP,4194/TCP,10255/TCP   3h41m


# Install the timesyncd package
sudo apt install systemd-timesyncd

# Enable and start the service
sudo systemctl enable --now systemd-timesyncd

# Unmask the service
sudo systemctl unmask systemd-timesyncd

# Start the service
sudo systemctl start systemd-timesyncd

============ store into snapshot

lxc stop k8master k8worker1
lxc snapshot k8master before-redis
lxc snapshot k8worker1 before-redis
lxc start k8master k8worker1


=========== restore using snapshot

lxc stop k8master k8worker1

lxc restore k8master before-helm4
lxc restore k8worker1 before-helm4

lxc start k8master k8worker1


=====================================

snap install helm --classic
helm version
version.BuildInfo{Version:"v4.2.3", GitCommit:"43e8b7feece8beb0fcba47059ec9b522fd929a64", GitTreeState:"clean", GoVersion:"go1.26.5", KubeClientVersion:"v1.36"}


helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update




helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 87.15.1 \
  --set nodeExporter.hostRootFsMount.enabled=true \
  --set kubelet.serviceMonitor.https=true

  root@k8master:/data/java/Hello/deploy# kubectl --namespace monitoring get pods -l "release=prometheus"
  NAME                                                   READY   STATUS    RESTARTS   AGE
  prometheus-kube-prometheus-operator-85779b6d8f-v5d9h   1/1     Running   0          77s
  prometheus-kube-state-metrics-66c48bcd7f-s9xvn         0/1     Running   0          77s
  prometheus-prometheus-node-exporter-8h74j              1/1     Running   0          77s
  prometheus-prometheus-node-exporter-bnxz4              1/1     Running   0          77s

root@k8master:/data/java/Hello/deploy# kubectl get pods -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          3m34s
prometheus-grafana-78b96b96cb-srx7h                      3/3     Running   0          3m56s
prometheus-kube-prometheus-operator-85779b6d8f-v5d9h     1/1     Running   0          3m56s
prometheus-kube-state-metrics-66c48bcd7f-s9xvn           1/1     Running   0          3m56s
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   0          3m34s
prometheus-prometheus-node-exporter-8h74j                1/1     Running   0          3m56s
prometheus-prometheus-node-exporter-bnxz4                1/1     Running   0          3m

root@k8master:/data/java/Hello/deploy# helm list -n monitoring
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
prometheus      monitoring      1               2026-07-13 00:08:10.219056747 +0000 UTC deployed        kube-prometheus-stack-87.15.1   v0.92.1

root@k8master:/data/java/Hello/deploy# curl -s  10.98.32.89
<a href="/login">Found</a>.

root@k8master:/data/java/Hello/deploy# curl -s k8master:30094
<a href="/login">Found</a>.

viswar@k8s:~$ curl -s k8master:30094
<a href="/login">Found</a>.


 lxc config show k8master --expanded




lxc config device add k8master promo proxy listen=tcp:0.0.0.0:9090 connect=tcp:192.168.100.10:31298
Device promo added to k8master

viswar@k8s:~$ lxc config device add k8master grafana proxy listen=tcp:0.0.0.0:30094 connect=tcp:192.168.100.10:30094
Device grafana added to k8master

root@k8master:/data/java/Hello/deploy# kubectl --namespace monitoring get pods -l "release=kube-prom-stack"
NAME                                                   READY   STATUS    RESTARTS   AGE
kube-prom-stack-kube-prome-operator-67d9b9cb69-l6cbz   1/1     Running   0          51s
kube-prom-stack-kube-state-metrics-6c4dc44b7c-95cqq    1/1     Running   0          51s
kube-prom-stack-prometheus-node-exporter-clg72         0/1     Pending   0          51s
kube-prom-stack-prometheus-node-exporter-gfmn4         0/1     Pending   0          51s

kubectl --namespace monitoring get secrets kube-prom-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

haeWitHweDQ2X14yZbwtymgCm1VYUcaXsH8E29zP

helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f values-monitoring.yaml


root@k8master:/data/java/Hello/deploy#  kubectl --namespace monitoring get pods -l "release=monitoring"
NAME                                                   READY   STATUS    RESTARTS   AGE
monitoring-kube-prometheus-operator-776b5c69df-95s5h   1/1     Running   0          69s
monitoring-kube-state-metrics-7f57b7f795-tdt7x         1/1     Running   0          69s
monitoring-prometheus-node-exporter-fbxsp              1/1     Running   0          69s
monitoring-prometheus-node-exporter-g8bqm              1/1     Running   0          69s

viswar@k8s:~$ lxc config device show k8master
eth0:
  ipv4.address: 192.168.100.10
  name: eth0
  network: k8sbr0
  type: nic
grafana:
  connect: tcp:192.168.100.10:30094
  listen: tcp:0.0.0.0:3000
  type: proxy
hello-ui-proxy:
  connect: tcp:192.168.100.10:30030
  listen: tcp:0.0.0.0:30030
  type: proxy
javaapi:
  connect: tcp:192.168.100.10:30080
  listen: tcp:0.0.0.0:30080
  type: proxy
kube-state-metrics:
  connect: tcp:192.168.100.10:30096
  listen: tcp:0.0.0.0:8080
  type: proxy
kubeapi:
  connect: tcp:192.168.100.10:6443
  listen: tcp:0.0.0.0:6443
  type: proxy
prometheus:
  connect: tcp:192.168.100.10:30090
  listen: tcp:0.0.0.0:9090
  type: proxy




viswar@k8s:~$ curl -s k8master:30094
<a href="/login">Found</a>.


PORT      STATE SERVICE
22/tcp    open  ssh
3000/tcp  open  ppp
6443/tcp  open  sun-sr-https
8080/tcp  open  http-proxy
8443/tcp  open  https-alt
9090/tcp  open  zeus-admin
30030/tcp open  unknown
30080/tcp open  unknown



lxc config device add k8master grafana proxy listen=tcp:0.0.0.0:3000 connect=tcp:192.168.100.10:30094
lxc config device remove k8master prometheus
lxc config device add k8master prometheus proxy listen=tcp:0.0.0.0:9090 connect=tcp:192.168.100.10:30090
lxc config device remove k8master kube-state-metrics
lxc config device add k8master kube-state-metrics proxy listen=tcp:0.0.0.0:8080 connect=tcp:192.168.100.10:30096



root@k8master:/data/java/Hello/deploy# kgp -n monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   0          29m
monitoring-grafana-54d96d48b-wf8j9                       3/3     Running   0          30m
monitoring-kube-prometheus-operator-776b5c69df-95s5h     1/1     Running   0          30m
monitoring-kube-state-metrics-7f57b7f795-tdt7x           1/1     Running   0          30m
monitoring-prometheus-node-exporter-fbxsp                1/1     Running   0          30m
monitoring-prometheus-node-exporter-g8bqm                1/1     Running   0          30m
prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   0          29m




root@k8master:/data/java/Hello/deploy# kubectl get servicemonitor -n monitoring
NAME                                                 AGE
hello-api                                            25m
monitoring-grafana                                   32m
monitoring-kube-prometheus-alertmanager              32m
monitoring-kube-prometheus-apiserver                 32m
monitoring-kube-prometheus-coredns                   32m
monitoring-kube-prometheus-kube-controller-manager   32m
monitoring-kube-prometheus-kube-etcd                 32m
monitoring-kube-prometheus-kube-proxy                32m
monitoring-kube-prometheus-kube-scheduler            32m
monitoring-kube-prometheus-kubelet                   32m
monitoring-kube-prometheus-operator                  32m
monitoring-kube-prometheus-prometheus                32m
monitoring-kube-state-metrics                        32m
monitoring-prometheus-node-exporter                  32m



root@k8master:/data/java/Hello/deploy# kubectl get endpoints -n default
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME            ENDPOINTS             AGE
hello-api-svc   10.244.2.187:8080     11h
hello-ui-svc    10.244.2.182:3000     11h
kubernetes      192.168.100.10:6443   8d
registry-svc    10.244.0.59:5000      11h






root@k8master:/data/java/Hello/deploy# kgs -n monitoring
NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP      63m
monitoring-grafana                        NodePort    10.98.242.180    <none>        80:30094/TCP                    64m
monitoring-kube-prometheus-alertmanager   NodePort    10.97.65.16      <none>        9093:30093/TCP,8080:32340/TCP   64m
monitoring-kube-prometheus-operator       ClusterIP   10.107.126.2     <none>        443/TCP                         64m
monitoring-kube-prometheus-prometheus     NodePort    10.106.129.199   <none>        9090:30090/TCP,8080:30858/TCP   64m
monitoring-kube-state-metrics             ClusterIP   10.105.56.134    <none>        8080/TCP                        64m
monitoring-prometheus-node-exporter       ClusterIP   10.103.11.183    <none>        9100/TCP                        64m
prometheus-operated                       ClusterIP   None             <none>        9090/TCP                        63m



root@k8master:/data/java/Hello/deploy# kubectl get endpoints -n monitoring
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME                                      ENDPOINTS                                               AGE
alertmanager-operated                     10.244.2.193:9094,10.244.2.193:9094,10.244.2.193:9093   64m
monitoring-grafana                        10.244.2.190:3000                                       65m
monitoring-kube-prometheus-alertmanager   10.244.2.193:8080,10.244.2.193:9093                     65m
monitoring-kube-prometheus-operator       10.244.2.196:10250                                      65m
monitoring-kube-prometheus-prometheus     10.244.2.194:9090,10.244.2.194:8080                     65m
monitoring-kube-state-metrics             10.244.2.189:8080                                       65m
monitoring-prometheus-node-exporter       192.168.100.10:9100,192.168.100.11:9100                 65m
prometheus-operated                       10.244.2.194:9090                                       64m

======================= to fix date unsync issue
date   # confirm current wrong time first
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on
timedatectl status   # ch

helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values-monitoring.yaml

kubectl rollout restart deployment monitoring-grafana -n monitoring
kubectl get statefulset -n monitoring
kubectl rollout restart statefulset prometheus-monitoring-kube-prometheus-prometheus -n monitoring

jvm_memory_used_bytes{service="hello-api-svc", area="heap"}
jvm_gc_pause_seconds_sum{service="hello-api-svc"}
jvm_threads_live_threads{service="hello-api-svc"}
process_cpu_usage{service="hello-api-svc"}

HTTP traffic — the metrics that actually matter day to day
http_server_requests_seconds_count{service="hello-api-svc"}

Rate of requests per endpoint over time:
rate(http_server_requests_seconds_count{service="hello-api-svc"}[5m])

Latency (p99, if histogram buckets are enabled):
histogram_quantile(0.99, rate(http_server_requests_seconds_bucket{service="hello-api-svc"}[5m]))


snap install helm --classic
helm version
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack   -n monitoring   -f values-monitoring.yaml
kubectl --namespace monitoring get pods -l "release=monitoring"
kgp -n monitoring
kubectl get servicemonitor -n monitoring

date fix should be at host
date   # confirm current wrong time first
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on
timedatectl status   # ch

helm upgrade monitoring prometheus-community/kube-prometheus-stack -n monitoring -f values-monitoring.yaml
kubectl rollout restart deployment monitoring-grafana -n monitoring
kubectl get statefulset -n monitoring
kubectl rollout restart statefulset prometheus-monitoring-kube-prometheus-prometheus -n monitoring
lxc config device add k8master grafana proxy listen=tcp:0.0.0.0:3000 connect=tcp:192.168.100.10:30094
lxc config device add k8master prometheus proxy listen=tcp:0.0.0.0:9090 connect=tcp:192.168.100.10:30090

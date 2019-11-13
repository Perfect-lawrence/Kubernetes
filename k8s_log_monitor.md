# k8s 日志、监控与应用管理

#### 大纲
* 监控集群组件
* 监控应用
* 管理组件日志
* 管理应用日志
* Deployment升级和回滚
* 配置应用的不同方式
* 应用的弹性伸缩
* 应用自我恢复

#### 监控集群组件

* 集群整体状态

```bash
source <(/opt/kubernetes/bin/kubectl completion bash)
kubectl cluster-info

```
* 更多集群信息

```bash
kubectl cluster-info dump

```
* 通过插件部署

```bash
kubectl get pod coredns-5b969f4c88-nh82w -n kube-system
kubectl describe pod/coredns-5b969f4c88-nh82w -n kube-system

```
* 组件 metrics

```bash
# netstat -nltp|grep 8080
tcp        0      0 127.0.0.1:8080          0.0.0.0:*               LISTEN      1130/kube-apiserver
# curl localhost:8080/stats/summary
{
  "paths": [
    "/apis",
    "/apis/",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/healthz",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/crd-informer-synced",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/metrics",
    "/openapi/v2",
    "/version"
  ]


```
* 组件健康状态

```bash
# curl localhost:8080/health
{
  "paths": [
    "/apis",
    "/apis/",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/healthz",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/crd-informer-synced",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/metrics",
    "/openapi/v2",
    "/version"
  ]
# curl -I localhost:8080/healthz/etcd
HTTP/1.1 200 OK
Date: Tue, 05 Nov 2019 22:44:38 GMT
Content-Length: 2
Content-Type: text/plain; charset=utf-8

```
#### Heapster + cAdvisor监控集群组件

```markdown
1、对接了Heapster或mitrics-server后展示Node cpu/内存/储存资源的消耗：
# kubectl top node 192.168.5.129
2、cAdvisor既能收集容器CPU、内存、文件系统和网络使用统计信息，还能采集节点资源使用情况
3、cAdvisor和Heapster都不能进行数据存储、趋势分析和报警。
4、因此，还需要将数据推送到InfluxDB，Grafana等后端进行存储和图形化展示。
Heapster即将被metrics-server替代
```
* 已经部署好的K8S Dashboard UI

```bash
# kubectl --namespace=kube-system get service kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.1.86.156   <none>        443:30036/TCP   56d

# kubectl get pods --all-namespaces -o wide |grep dashboard
kube-system   kubernetes-dashboard-85bcf5dbf8-zgdqr   1/1     Running            0          2d20h   10.2.52.54   192.168.5.129   <none>           <none>

# kubectl describe pod  kubernetes-dashboard-85bcf5dbf8-zgdqr -n kube-system
# kubectl --namespace=kube-system get deployment kubernetes-dashboard
# kubectl describe pod -n kube-system  kubernetes-dashboard-85bcf5dbf8-nnm6x

# kubectl get service --namespace=kube-system kubernetes-dashboard
NAME                   TYPE       CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.1.17.89   <none>        443:30036/TCP   8m30s

# kubectl get deployments -n kube-system

```
* 火狐浏览：https://node节点IP:300036/ 
* https://192.168.5.129:30036

```bash
# token
# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')


 curl localhost:8080/apis/rbac.authorization.k8s.io/v1/clusterroles/cluster-admin
{
  "paths": [
    "/apis",
    "/apis/",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/healthz",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/crd-informer-synced",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/metrics",
    "/openapi/v2",
    "/version"
  ]


```
* 监控应用

```bash
# kubectl describe pod -n kube-system kubernetes-dashboard-85bcf5dbf8-nnm6x  

# kubectl get  pod heapster-55fd6fcdd8-p7tnl -n kube-system -o wide 

```
* 组件metrics

```bash
# curl https://192.168.5.130:10250/stats/summary -k

```

* 组件监控状况

```bash
# curl https://192.168.5.130:10250/healthz -k   
ok

# curl https://192.168.5.130:10250/healthz/ping -k


```
* 查看资源消耗

```bash
# kubectl get pod --namespace kube-system kubernetes-dashboarf5dbf8-nnm6x  --watch

```
#### 管理k8s组件日志

* 组件日志：

```bash
/var/log/kube-apiserver.log
/var/log/kube-proxy.log
/var/log/kube-controller-manager.log
/var/log/kubelet.log
```

* 使用 systemd管理：

```bash
# journalctl -u kube-apiserver
```
* 使用k8s插件部署：

```bash
# kubectl logs --namespace kube-system -f coredns-5b969f4c88-nh82w

```

#### 管理k8s应用日志

* 从容器标准输出截获：

```bash
# kubectl logs -f {pod name} -c {container name}

# kubectl logs -f {docker name}

# kubectl get svc 
######### on node   #####
# curl -I 10.1.19.226
# kubectl logs -f  my-nginx-9576fbbbb-8pb4n

# kubectl logs -f my-nginx-9576fbbbb-8pb4n  -c my-nginx

```
* 进入容器里

```bash
# kubectl get pods
NAME                        READY   STATUS    RESTARTS   AGE
my-nginx-9576fbbbb-8pb4n    1/1     Running   0          4d
my-nginx-9576fbbbb-sgsxf    1/1     Running   0          4d
net-test-59ff94d98d-d69dz   1/1     Running   0          4d
net-test-59ff94d98d-mg8pg   1/1     Running   0          4d
nginx-ds-55w86              1/1     Running   1          154d
nginx-ds-w4r2t              1/1     Running   3          154d

# kubectl exec -it my-nginx-9576fbbbb-8pb4n -c my-nginx /bin/bash


```

#### Deployment升级与回滚-1

* 创建Deployment

```bash
# kubectl run {deployment} --image={image} --replicas={rep.}
or yaml 
]# kubectl get deploy
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
my-nginx   2/2     2            2           58d
net-test   2/2     2            2           161d
# kubectl set image deployment/my-nginx my-nginx=nginx:latest
deployment.extensions/my-nginx image updated
# kubectl get deploy/my-nginx -o wide
# kubectl set resources deployment/net-test -c net-test --limits=cpu=200m,memory=256Mi
deployment.extensions/net-test resource requirements updated

```
#### Deployment升级与回滚-2

* 暂停Deployment

```bash
# kubectl rollout pause deploy/my-nginx
deployment.extensions/my-nginx paused


#  kubectl set image deployment/my-nginx my-nginx=nginx:1.14.1
deployment.extensions/my-nginx image updated


```
* 恢复Deployment：

```bash
# kubectl rollout resume deployment/my-nginx
deployment.extensions/my-nginx resumed

# kubectl set image deployment/my-nginx my-nginx=nginx:1.16.0

```

* 查看升级状态：

```bash
# kubectl rollout status deployment/my-nginx
deployment "my-nginx" successfully rolled out

```

* 查询升级历史：

```bash
]# kubectl rollout history deployment/my-nginx
deployment.extensions/my-nginx
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>

# kubectl rollout history deployment/my-nginx --revision=2
deployment.extensions/my-nginx with revision #2
Pod Template:
  Labels:       pod-template-hash=f475bf5b6
        run=my-nginx
  Containers:
   my-nginx:
    Image:      nginx:latest
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>
  
# kubectl rollout history deployment/my-nginx --revision=4
deployment.extensions/my-nginx with revision #4
Pod Template:
  Labels:       pod-template-hash=55d8ccb8fc
        run=my-nginx
  Containers:
   my-nginx:
    Image:      nginx:1.16.0
    Port:       80/TCP
    Host Port:  0/TCP
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>


```

* 回滚：

```bash
# kubectl rollout undo deployment/my-nginx --to-revision=2
deployment.extensions/my-nginx rolled back
# kubectl rollout status deployment/my-nginx
deployment "my-nginx" successfully rolled out

# kubectl rollout undo deployment/my-nginx --to-revision=4
deployment.extensions/my-nginx rolled back
# kubectl rollout status deployment/my-nginx
deployment "my-nginx" successfully rolled out

```

#### 应用弹性伸缩

```bash
# kubectl scale deployment net-test --replicas=6
deployment.extensions/net-test scaled
# kubectl get  deployment net-test
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
net-test   4/6     6            4           162d

```

* 对接了heapster，和HPA联动后：

```bash
# kubectl autoscale deployment net-test --min=2 --max=6 --cpu-percent=20
horizontalpodautoscaler.autoscaling/net-test autoscaled


```

#### 应用自恢复： restartPolicy + livenessProbe

```bash
Pod Restart Policy: Always,OnFailure,Never
liveneessProbe: http/https Get,Shell exec, tcpSocket
# tcp socket的liveness探针 +  always restart 例子
```
```yaml

apiVersion: v1
kind: Pod
metadata:
  name: goproxy
spec:
  restartPolicy: Always
  containers:
  - name: goproxy
    image: k8s.gcr.io/goproxy:0.1
    ports:
    - containerPort: 8080
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySecondes: 15
      periodSeconds: 20
```

* 缩容

```bash
# kubectl scale deployment net-test --replicas=2
deployment.extensions/net-test scaled


```

#### 创建一个应用

```bash
# kubectl run redis --image=redis --replicas=2

# kubectl run postgresql --image=postgres --replicas=2
# kubectl run k3s-nginx --image=nginx:latest --dry-run
# kubectl run k3s-nginx --image=nginx:latest --replicas=2 
# kubectl expose deployment k3s-nginx  --port=8090 --target-port=80 --type=NodePort

### Pod
# kubectl run k8s-pg --generator=run-pod/v1 --image=postgres:latest --dry-run --replicas=2 --port=5432 -o yaml > pg-pod.yaml


# kubectl run k8s-pg --image=postgres --restart=Never --port=5432 --labels="app=pg-db,env=test"
pod/k8s-pg created

# kubectl get pod/k8s-pg
NAME     READY   STATUS    RESTARTS   AGE
k8s-pg   1/1     Running   0          46m
# kubectl rollout undo deployment net-test --to-revision=1
deployment.extensions/net-test rolled back

```

* 无状态(Deployment) 有状态(STatefulSet) 

#实操部分
* 创建一个pod

```BASH
# kubectl run test-golang --image=golange:v1.13.4 --replicas=2
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/test-golang created

# docker load -i golang_v1.13.4.tar
831b66a484dc: Loading layer [==================================================>]  119.2MB/119.2MB
9674e3075904: Loading layer [==================================================>]  17.11MB/17.11MB
7a435d49206f: Loading layer [==================================================>]  17.85MB/17.85MB
2ea751c0f96c: Loading layer [==================================================>]  149.8MB/149.8MB
164116942aa4: Loading layer [==================================================>]  184.3MB/184.3MB
126db7aa380d: Loading layer [==================================================>]  335.1MB/335.1MB
44d7af965eea: Loading layer [==================================================>]   2.56kB/2.56kB
Loaded image: golang:v1.13.4


```

# 创建pod和deployment

```bash
# kubectl run my-test-nginx --image=nginx:1.16.0 --replicas=2
# kubectl logs  -f my-test-nginx-78d7b4dfd-5jm9c -c my-test-nginx
# kubectl exec -it my-test-nginx-78d7b4dfd-5jm9c bash

# kubectl run my-flask-web --image=flask_web:v1 --replicas=2 --service-generator='service/v2' --expose --port=5000



# kubectl run my-flask-web --image=flask_web:v1 --replicas=2 --service-generator='service/v2' --generator=deployment/apps.v1 --generator=run-pod/v1 --expose --port=5000 --dry-run -o yaml > ./flask2.yaml

```

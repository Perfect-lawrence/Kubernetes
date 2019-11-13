# 升级操作

* 资源升级

```bash
# kubectl set resources deploy my-nginx -c=my-nginx --limits=cpu=200m,memory=256Mi
deployment.extensions/my-nginx resource requirements updated
# kubectl rollout history deploy my-nginx
deployment.extensions/my-nginx
REVISION  CHANGE-CAUSE
3         <none>
5         <none>
6         <none>
7         <none>

# kubectl rollout history deploy my-nginx --revision=7
deployment.extensions/my-nginx with revision #7
Pod Template:
  Labels:       pod-template-hash=776969d97
        run=my-nginx
  Containers:
   my-nginx:
    Image:      nginx:1.16.0
    Port:       80/TCP
    Host Port:  0/TCP
    Limits:            --这里出现资源操作
      cpu:      200m
      memory:   256Mi
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>


```

* 回滚操作

```bash
# kubectl rollout undo deployment/my-nginx --to-revision=6
deployment.extensions/my-nginx rolled back

```

* 弹性伸缩

```bash
Examples:
  # Scale a replicaset named 'foo' to 3.
  kubectl scale --replicas=3 rs/foo

  # Scale a resource identified by type and name specified in "foo.yaml" to 3.
  kubectl scale --replicas=3 -f foo.yaml

  # If the deployment named mysql's current size is 2, scale mysql to 3.
  kubectl scale --current-replicas=2 --replicas=3 deployment/mysql

  # Scale multiple replication controllers.
  kubectl scale --replicas=5 rc/foo rc/bar rc/baz

  # Scale statefulset named 'web' to 3.
  kubectl scale --replicas=3 statefulset/web
  

# kubectl run my-flask-web --image=flask_web:v1 --replicas=1
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/my-flask-web created

# kubectl get pod my-flask-web-794c665545-ksr2q -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP          NODE            NOMINATED NODE   READINESS GATES
my-flask-web-794c665545-ksr2q   1/1     Running   0          73s   10.2.4.51   192.168.5.130   <none>           <none>

# kubectl get deploy my-flask-web
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
my-flask-web   1/1     1            1           112s

# kubectl scale deployment my-flask-web --replicas=4 --record
deployment.extensions/my-flask-web scaled  --升级到4个副本
# kubectl get deployment my-flask-web
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
my-flask-web   4/4     4            4           3m58s   ---由1 变成4

-- 查看记录
# kubectl rollout status deployment my-flask-web
deployment my-flask-web successfully rolled out
# kubectl rollout history deployment my-flask-web
deployment.extensions/my-flask-web
REVISION  CHANGE-CAUSE
1         kubectl scale deployment my-flask-web --replicas=4 --record=true

--- 能看到 version  1 操作记录
# kubectl rollout history deployment my-flask-web --revision=1
deployment.extensions/my-flask-web with revision #1
Pod Template:
  Labels:       pod-template-hash=794c665545
        run=my-flask-web
  Annotations:  kubernetes.io/change-cause: kubectl scale deployment my-flask-web --replicas=4 --record=true
  Containers:
   my-flask-web:
    Image:      flask_web:v1
    Port:       <none>
    Host Port:  <none>
    Environment:        <none>
    Mounts:     <none>
  Volumes:      <none>


```

* 自动缩容和扩容

```bash

Examples:
  # Auto scale a deployment "foo", with the number of pods between 2 and 10, no
target CPU utilization specified so a default autoscaling policy will be used:
  kubectl autoscale deployment foo --min=2 --max=10

  # Auto scale a replication controller "foo", with the number of pods between 1
and 5, target CPU utilization at 80%:
  kubectl autoscale rc foo --max=5 --cpu-percent=80


# kubectl autoscale deployment my-flask-web --min=1 --max=2
horizontalpodautoscaler.autoscaling/my-flask-web autoscaled
-- 4个副本到2个副本
# kubectl get pods
NAME                             READY   STATUS        RESTARTS   AGE
my-flask-web-794c665545-d98wf    0/1     Terminating   0          12m  
my-flask-web-794c665545-h86qf    0/1     Terminating   0          12m
my-flask-web-794c665545-ksr2q    1/1     Running       0          15m
my-flask-web-794c665545-nh65w    1/1     Running       0          12m

# kubectl scale deployment my-flask-web --replicas=1 --record
deployment.extensions/my-flask-web scaled


# kubectl autoscale deployment my-flask-web --max=2 --cpu-percent=50 --record --dry-run -o yaml > flask-autoscale-deployment.yaml
```

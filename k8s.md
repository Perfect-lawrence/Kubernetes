### Kubernetes 核心概念

* Kubernetes（k8s）是自动化容器操作的开源平台，这些操作包括部署，调度和节点集群间扩展。如果你曾经用过Docker容器技术部署容器，那么可以将Docker看成Kubernetes内部使用的低级别组件。Kubernetes不仅仅支持Docker，还支持Rocket，这是另一种容器技术

# 使用Kubernetes可以干啥

* 自动化容器的部署和复制
* 随时扩展或收缩容器规模
* 将容器组织成组，并且提供容器间的负载均衡
* 很容易地升级应用程序容器的新版本
* 提供容器弹性，如果容器失效就替换它
* 


# 
```bash
kubectl explain replicaset
kubectl edit deply/foo
 kubectl completion -h
source <(kubectl completion bash) 

 kubectl run --image=nginx my-deploy -a yaml --dry-run > my-deploy.yaml
 
kubectl get statefulset/foo -o=yaml --export > new.yaml

kubectl explain pod.spec.affinity.PodAffinity

kubectl exec
kubectl describe pod shell-demo
kubectl get pod shell-demo
kubectl exec -it shell-demo /bin/bash
 kubectl exec shell-demo env
 
kubectl exec shell-demo cat /etc/passwd

```
```bash
kubectl api-resources
NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND
bindings                                                                      true         Binding
componentstatuses                 cs                                          false        ComponentStatus
configmaps                        cm                                          true         ConfigMap
endpoints                         ep                                          true         Endpoints
events                            ev                                          true         Event
limitranges                       limits                                      true         LimitRange
namespaces                        ns                                          false        Namespace
nodes                             no                                          false        Node
persistentvolumeclaims            pvc                                         true         PersistentVolumeClaim
persistentvolumes                 pv                                          false        PersistentVolume
pods                              po                                          true         Pod
podtemplates                                                                  true         PodTemplate
replicationcontrollers            rc                                          true         ReplicationController
resourcequotas                    quota                                       true         ResourceQuota
secrets                                                                       true         Secret
serviceaccounts                   sa                                          true         ServiceAccount
services                          svc                                         true         Service
mutatingwebhookconfigurations                  admissionregistration.k8s.io   false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io   false        ValidatingWebhookConfiguration
customresourcedefinitions         crd,crds     apiextensions.k8s.io           false        CustomResourceDefinition
apiservices                                    apiregistration.k8s.io         false        APIService
controllerrevisions                            apps                           true         ControllerRevision
daemonsets                        ds           apps                           true         DaemonSet
deployments                       deploy       apps                           true         Deployment
replicasets                       rs           apps                           true         ReplicaSet
statefulsets                      sts          apps                           true         StatefulSet
tokenreviews                                   authentication.k8s.io          false        TokenReview
localsubjectaccessreviews                      authorization.k8s.io           true         LocalSubjectAccessReview
selfsubjectaccessreviews                       authorization.k8s.io           false        SelfSubjectAccessReview
selfsubjectrulesreviews                        authorization.k8s.io           false        SelfSubjectRulesReview
subjectaccessreviews                           authorization.k8s.io           false        SubjectAccessReview
horizontalpodautoscalers          hpa          autoscaling                    true         HorizontalPodAutoscaler
cronjobs                          cj           batch                          true         CronJob
jobs                                           batch                          true         Job
certificatesigningrequests        csr          certificates.k8s.io            false        CertificateSigningRequest
leases                                         coordination.k8s.io            true         Lease
events                            ev           events.k8s.io                  true         Event
daemonsets                        ds           extensions                     true         DaemonSet
deployments                       deploy       extensions                     true         Deployment
ingresses                         ing          extensions                     true         Ingress
networkpolicies                   netpol       extensions                     true         NetworkPolicy
podsecuritypolicies               psp          extensions                     false        PodSecurityPolicy
replicasets                       rs           extensions                     true         ReplicaSet
ingresses                         ing          networking.k8s.io              true         Ingress
networkpolicies                   netpol       networking.k8s.io              true         NetworkPolicy
runtimeclasses                                 node.k8s.io                    false        RuntimeClass
poddisruptionbudgets              pdb          policy                         true         PodDisruptionBudget
podsecuritypolicies               psp          policy                         false        PodSecurityPolicy
clusterrolebindings                            rbac.authorization.k8s.io      false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io      false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io      true         RoleBinding
roles                                          rbac.authorization.k8s.io      true         Role
priorityclasses                   pc           scheduling.k8s.io              false        PriorityClass
csidrivers                                     storage.k8s.io                 false        CSIDriver
csinodes                                       storage.k8s.io                 false        CSINode
storageclasses                    sc           storage.k8s.io                 false        StorageClass
volumeattachments                              storage.k8s.io                 false        VolumeAttachment

```

```bash


# A configuration file describes clusters, users, and contexts. Your config-demo file has the framework to describe two clusters, two users, and three contexts.
# Go to your config-exercise directory. Enter these commands to add cluster details to your configuration file: 


kubectl config --kubeconfig=config-demo set-cluster development --server=https://1.2.3.4 --certificate-authority=fake-ca-file
kubectl config --kubeconfig=config-demo set-cluster scratch --server=https://5.6.7.8 --insecure-skip-tls-verify
# Add user details to your configuration file:
kubectl config --kubeconfig=config-demo set-credentials developer --client-certificate=fake-cert-file --client-key=fake-key-seefile
kubectl config --kubeconfig=config-demo set-credentials experimenter --username=exp --password=some-password

```
```bash
kubectl config view
kubectl cluster-info
curl http://localhost:8080/api/


APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")

```

```bash
curl https://192.168.5.128:6443/api --header "Authorization: Bearer $(kubectl describe secret default-token-fzq7r |grep -E '^token' | cut -f2 -d':' | tr -d " ")" --insecure


```

# Node

#### 给node增加一个label和删除label

```bash
[root@server01 addon-manager]# kubectl label node 192.168.5.129 env=test
node/192.168.5.129 labeled
[root@server01 addon-manager]# kubectl label node 192.168.5.129 DB=postgresql
node/192.168.5.129 labeled

[root@server01 addon-manager]# kubectl get node 192.168.5.129 --show-labels
NAME            STATUS   ROLES    AGE    VERSION   LABELS
192.168.5.129   Ready    <none>   155d   v1.14.0   DB=postgresql,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,env=test,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.129,kubernetes.io/os=linux

```

### 给node删除label

```bash
[root@server01 addon-manager]# kubectl label node 192.168.5.129 DB-
node/192.168.5.129 labeled
[root@server01 addon-manager]# kubectl label node 192.168.5.129 env-
node/192.168.5.129 labeled
[root@server01 addon-manager]# kubectl get node 192.168.5.129 --show-labels
NAME            STATUS   ROLES    AGE    VERSION   LABELS
192.168.5.129   Ready    <none>   155d   v1.14.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.129,kubernetes.io/os=linux

```

### 给node role项设置label

```bash
[root@server01 addon-manager]# kubectl label node 192.168.5.129 node-role.kubernetes.io/work=
node/192.168.5.129 labeled

[root@server01 addon-manager]# kubectl get node --show-labels
NAME            STATUS   ROLES    AGE    VERSION   LABELS
192.168.5.129   Ready    work     155d   v1.14.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.129,kubernetes.io/os=linux,node-role.kubernetes.io/work=
192.168.5.130   Ready    <none>   155d   v1.14.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.130,kubernetes.io/os=linux

[xiangxh@server01 bin]$ kubectl label node 192.168.5.130 node-role.kubernetes.io/work=
node/192.168.5.130 labeled

[xiangxh@server01 bin]$ kubectl get nodes --show-labels
NAME            STATUS   ROLES   AGE    VERSION   LABELS
192.168.5.129   Ready    work    155d   v1.14.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.129,kubernetes.io/os=linux,node-role.kubernetes.io/work=
192.168.5.130   Ready    work    155d   v1.14.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.5.130,kubernetes.io/os=linux,node-role.kubernetes.io/work=
[xiangxh@server01 bin]$ kubectl get nodes
NAME            STATUS   ROLES   AGE    VERSION
192.168.5.129   Ready    work    155d   v1.14.0
192.168.5.130   Ready    work    155d   v1.14.0
```
https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/

$ kubectl run k3s-nginx --image=nginx:latest --dry-run
$ kubectl run k3s-nginx --image=nginx:latest --replicas=2 
$ kubectl expose deployment k3s-nginx  --port=8090 --target-port=80 --type=LoadBalancer

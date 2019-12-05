# kubernetes lab Chapter 5 APIs and Access

### Exercise 5.1: Configuring TLS Access
* 1. Begin by reviewing the kubectl configuration file. We will use the three certificates and the API server address
* 2.We will set the certificates as variables. You may want to double-check each parameter as you set it. Begin with setting
the client-certificate-data key.
* 3. Almost the same command, but this time collect the client-key-data as the key variable.
* 4. Finally set the auth variable with the certificate-authority-data key.


```bash
# less ~/.kube/config
# export client=$(grep client-cert ~/.kube/config |cut -d" " -f 6)
# echo $client
LS0tLS1CRUdJTiB......
# export key=$(grep client-key-data ~/.kube/config|cut -d " " -f 6)
# echo $key
LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tL.......

# export auth=$(grep certificate-authority-data ~/.kube/config |cut -d " " -f 6)

# echo $auth
LS0tLS1CRUdJTiBDRVJUSUZJQ0.....
```

* 5. Now encode the keys for use with curl.
* 6. Pull the API server URL from the config file
* 7. Use curl command and the encoded keys to connect to the API server
* 8. If the previous command was successful, create a JSON file to create a new pod.
* 9. The previous curl command can be used to build a XPOST API call. There will be a lot of output, including the scheduler
and taints involved. Read through the output. In the last few lines the phase will probably show Pending, as it’s near the
beginning of the creation process.
* 10. Verify the new pod exists.

```bash
# echo $client |base64 -d - > ./client.pem
# echo $key|base64 -d - > ./client-key.pem
# echo $auth | base64 -d - > ./ca.pem
# ls
ca.pem  client-key.pem  client.pem
# kubectl config view |grep server
    server: https://192.168.5.128:6443
# curl --cert ./client.pem --key ./client-key.pem  --cacert ./ca.pem  https://192.168.5.128:6443/api/v1/pods
{
  "kind": "PodList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/pods",
    "resourceVersion": "19546665"
  },
  "items": [
    {
      "metadata": {
        "name": "coredns-5b969f4c88-s27sk",
        "generateName": "coredns-5b969f4c88-",
        "namespace": "kube-system",
        "selfLink": "/api/v1/namespaces/kube-system/pods/coredns-5b969f4c88-s27sk",
        "uid": "52a422ff-16f8-11ea-9203-000c29f3984b",
        "resourceVersion": "19531673",
        "creationTimestamp": "2019-12-05T00:43:58Z",
        "labels": {
          "k8s-app": "kube-dns",
          "pod-template-hash": "5b969f4c88"
        },
...................
..................

# curl --cert ./client.pem --key ./client-key.pem  --cacert ./ca.pem  https://192.168.5.128:6443/api/v1/namespaces/default/pods  -XPOST -H 'Content-Type: application/json' -d @curlpod.json
{
  "kind": "Pod",
  "apiVersion": "v1",
  "metadata": {
    "name": "curlpod",
    "namespace": "default",
    "selfLink": "/api/v1/namespaces/default/pods/curlpod",
    "uid": "b32641bd-1714-11ea-9203-000c29f3984b",
    "resourceVersion": "19547562",
    "creationTimestamp": "2019-12-05T04:07:06Z",
    "labels": {
      "name": "examplepod"
    }
  },
  "spec": {
    "volumes": [
      {
        "name": "default-token-fzq7r",
................................
....................................
# kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
curlpod   1/1     Running   0          14s


```

### Exercise 5.2: Explore API Calls

* 1. One way to view what a command does on your behalf is to use strace. In this case, we will look for the current
endpoints, or targets of our API calls.
* 2. Run this command again, preceded by strace. You will get a lot of output. Near the end you will note several openat
functions to a local directory，/root/.kube/cache/discovery/192.168.5.128_6443/
* 3. Change to the parent directory and explore. Your endpoint IP will be different, so replace the following with one suited
to your system.
* 4. View the contents. You will find there are directories with various configuration information for kubernetes.
* 5. Use the find command to list out the subfiles. The prompt has been modified to look better on this page.

* 6. View the objects available in version 1 of the API. For each object, or kind:, you can view the verbs or actions for that
object, such as create seen in the following example. Note the prompt has been truncated for the command to fit on one
line.
* 7. Some of the objects have shortNames, which makes using them on the command line much easier. Locate the
shortName for endpoints.
* 8. Use the shortName to view the endpoints. It should match the output from the previous command
* 9. We can see there are 37 objects in version 1 file.
* 10. Looking at another file we find seven more.
* 11. Delete the curlpod to recoup system resources
* 12. Take a look around the other files as time permits.

```bash
# kubectl get endpoints
NAME              ENDPOINTS            AGE
kubernetes        192.168.5.128:6443   189d
my-flask          <none>               20d
my-nginx          <none>               86d
my-svc-headless   <none>               20d
my-svc-np         <none>               21d
nginx-ds          <none>               182d

# yum install strace -y

# strace kubectl get endpoints
execve("/opt/kubernetes/bin/kubectl", ["kubectl", "get", "endpoints"], [/* 25 vars */]) = 0
arch_prctl(ARCH_SET_FS, 0x2d23f30)      = 0
sched_getaffinity(0, 8192, [0 1 2 3])   = 16
mmap(NULL, 262144, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fdf3adff000
..................
# cd /root/.kube/cache/discovery/
# ls
127.0.0.1_8080  192.168.5.128_6443
# cd 192.168.5.128_6443/
# ls
admissionregistration.k8s.io  authorization.k8s.io  events.k8s.io      rbac.authorization.k8s.io
apiextensions.k8s.io          autoscaling           extensions         scheduling.k8s.io
apiregistration.k8s.io        batch                 networking.k8s.io  servergroups.json
apps                          certificates.k8s.io   node.k8s.io        storage.k8s.io
authentication.k8s.io         coordination.k8s.io   policy             v1

# find .
.
./servergroups.json
./node.k8s.io
./node.k8s.io/v1beta1
./node.k8s.io/v1beta1/serverresources.json
./extensions
./extensions/v1beta1
./extensions/v1beta1/serverresources.json
./authorization.k8s.io
./authorization.k8s.io/v1beta1
./authorization.k8s.io/v1beta1/serverresources.json
./authorization.k8s.io/v1
./authorization.k8s.io/v1/serverresources.json
./rbac.authorization.k8s.io
...................................
# python -m json.tool v1/serverresources.json 
{
    "apiVersion": "v1",
    "groupVersion": "v1",
    "kind": "APIResourceList",
    "resources": [
        {
            "kind": "Binding",
            "name": "bindings",
            "namespaced": true,
            "singularName": "",
            "verbs": [
                "create"
            ]
        },
        {
            "kind": "ComponentStatus",
            "name": "componentstatuses",
            "namespaced": false,
            "shortNames": [
                "cs"
            ],
................

# python -m json.tool v1/serverresources.json |more
{
    "apiVersion": "v1",
    "groupVersion": "v1",
    "kind": "APIResourceList",
    "resources": [
        {
            "kind": "Binding",
            "name": "bindings",
            "namespaced": true,
            "singularName": "",
            "verbs": [
                "create"
            ]
        },
        {
            "kind": "ComponentStatus",
            "name": "componentstatuses",
            "namespaced": false,
...........
# kubectl get ep
NAME              ENDPOINTS            AGE
kubernetes        192.168.5.128:6443   189d
my-flask          <none>               20d
my-nginx          <none>               86d
my-svc-headless   <none>               20d
my-svc-np         <none>               21d
nginx-ds          <none>               182d

# python -m json.tool v1/serverresources.json |grep kind
    "kind": "APIResourceList",
            "kind": "Binding",
            "kind": "ComponentStatus",
            "kind": "ConfigMap",
            "kind": "Endpoints",
            "kind": "Event",
            "kind": "LimitRange",
            "kind": "Namespace",
            "kind": "Namespace",
            "kind": "Namespace",
            "kind": "Node",
            "kind": "NodeProxyOptions",
            "kind": "Node",
            "kind": "PersistentVolumeClaim",
            "kind": "PersistentVolumeClaim",
            "kind": "PersistentVolume",
            "kind": "PersistentVolume",
            "kind": "Pod",
            "kind": "PodAttachOptions",
            "kind": "Binding",
            "kind": "Eviction",
            "kind": "PodExecOptions",
            "kind": "Pod",
            "kind": "PodPortForwardOptions",
            "kind": "PodProxyOptions",
            "kind": "Pod",
            "kind": "PodTemplate",
            "kind": "ReplicationController",
            "kind": "Scale",
            "kind": "ReplicationController",
            "kind": "ResourceQuota",
            "kind": "ResourceQuota",
            "kind": "Secret",
            "kind": "ServiceAccount",
            "kind": "Service",
            "kind": "ServiceProxyOptions",
            "kind": "Service",
# python -m json.tool apps/v1beta1/serverresources.json |grep kind
    "kind": "APIResourceList",
            "kind": "ControllerRevision",
            "kind": "Deployment",
            "kind": "DeploymentRollback",
            "kind": "Scale",
            "kind": "Deployment",
            "kind": "StatefulSet",
            "kind": "Scale",
            "kind": "StatefulSet",

# kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
curlpod   1/1     Running   0          60m
# kubectl delete pod curlpod
pod "curlpod" deleted
# kubectl get po
No resources found.




```

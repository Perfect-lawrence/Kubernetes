# kubernetes Chapter 6 API Objects

## Exercise 6.1: RESTful API Access

### RESTful API Access

* We will use the curl command to make API requests to the cluster, in an in-secure manner. Once we know the IP address
and port, then the token we can retrieve cluster data in a RESTful manner. By default most of the information is restricted, but
changes to authentication policy could allow more access.

* 1. First we need to know the IP and port of a node running a replica of the API server. The master system will typically
have one running. Use kubectl config view to get overall cluster configuration, and find the server entry. This will give
us both the IP and the port.

```bash
# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.5.128:6443
  name: kubernetes
.............

```
* 2. Next we need to find the bearer token. This is part of a default token. Look at a list of tokens, first all on the cluster, then
just those in the default namespace. There will be a secret for each of the controllers of the cluster.\

```bash
# kubectl get secrets --all-namespaces
NAMESPACE         NAME                                     TYPE                                  DATA   AGE
default           default-token-fzq7r                      kubernetes.io/service-account-token   3      189d
kube-node-lease   default-token-qjvkk                      kubernetes.io/service-account-token   3      189d
kube-public       default-token-mg9tq                      kubernetes.io/service-account-token   3      189d
kube-system       coredns-token-5hd68                      kubernetes.io/service-account-token   3      169d
kube-system       default-token-b7pqz                      kubernetes.io/service-account-token   3      189d
kube-system       kubernetes-dashboard-admin-token-5fvsn   kubernetes.io/service-account-token   3      29d
kube-system       kubernetes-dashboard-certs               Opaque                                0      29d
kube-system       kubernetes-dashboard-key-holder          Opaque                                2      29d
kube-system       kubernetes-dashboard-token-lxz9f         kubernetes.io/service-account-token   3      29d
low-usage-limit   default-token-9nhtw                      kubernetes.io/service-account-token   3      16d
mem-example       default-token-ttqrv                      kubernetes.io/service-account-token   3      161d
sock-shop         default-token-wcs7n                      kubernetes.io/service-account-token   3      5h30m
```

* 3. Look at the details of the secret. We will need the token: information from the output.

```bash
# kubectl describe secrets  default-token-fzq7r
Name:         default-token-fzq7r
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: 9d91ed6e-81d4-11e9-a085-000c29f3984b

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1363 bytes
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tZnpxN3IiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjlkOTFlZDZlLTgxZDQtMTFlOS1hMDg1LTAwMGMyOWYzOTg0YiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.VMKhOfIVZXfMDNBWlat3xjnZM88-po70UOU9Tun67mEqMLMwA4Rx-ce30-xXplWl82QkKE_XysJRl-27vVAV-JTCOcclsHfCl4YRVulv58k7KtgbzcAFK_iDdghWM-BBKeGyleymK9Y41HSyvoQtKAYQRj3vP-m8iP5L4U0PSGe0GlBKtY4i0FaLmRTa9khohrm_AnV96dpNFi01wRvYPN3mLC99sasojKZr-aSxSmZWwtLpdCzYLTKPNkUg6JG8nw_5iKkMmbmBxgp-cYtZADvSU4KOzQgqwovbSzVCJ0yeLngFkwzzqjtw2uM6kIKXO5vz066GI2bqqrZ3oVtz4g
```

* 4. Using your mouse to cut and paste or cut or awk save the data, from the first character eyJh to the last, EFmBWA to a
variable named token. Your token data will be different.

```bash
# export  token=$(kubectl describe secret default-token-fzq7r |grep ^token|cut -d " " -f 7)

```

* 5. Test to see if you can get basic API information from your cluster. We will pass it the server name and port, the token
and use the -k option to avoid using a cert.
* 6. Try the same command, but look at API v1.
* 7. Now try to get a list of namespaces. This should return an error. It shows our request is being seen as
system:serviceaccount.

```bash
# curl https://192.168.5.128:6443/apis --header "Authorization: Bearer $token" -k
{
  "kind": "APIGroupList",
  "apiVersion": "v1",
  "groups": [
    {
      "name": "apiregistration.k8s.io",
      "versions": [
        {
          "groupVersion": "apiregistration.k8s.io/v1",
          "version": "v1"
        },
...................

# curl https://192.168.5.128:6443/api/v1 --header "Authorization: Bearer $token" -k
{
  "kind": "APIResourceList",
  "groupVersion": "v1",
  "resources": [
    {
      "name": "bindings",
      "singularName": "",
      "namespaced": true,
      "kind": "Binding",
      "verbs": [
        "create"
      ]
    },
    {
      "name": "componentstatuses",
      "singularName": "",
...............
# curl https://192.168.5.128:6443/api/v1/namespaces --header "Authorization: Bearer $token" -k
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "namespaces is forbidden: User \"system:serviceaccount:default:default\" cannot list resource \"namespaces\" in API group \"\" at the cluster scope",
  "reason": "Forbidden",
  "details": {
    "kind": "namespaces"
  },
  "code": 403


```
* 8. Pods can also make use of included certificates to use the API. The certificates are automatically made available to
a pod under the /var/run/secrets/kubernetes.io/serviceaccount/. We will deploy a simple Pod and view the
resources. If you view the token file you will find it is the same value we put into the $token variable.


```bash
# kubectl run  -i -t k8s-lab-busybox --image=busybox:1.28 --restart=Never
If you don't see a command prompt, try pressing enter.
/ # ls /var/run/secrets/kubernetes.io/serviceaccount/
ca.crt     namespace  token
/ #

# kubectl get pod
NAME              READY   STATUS      RESTARTS   AGE
k8s-lab-busybox   0/1     Completed   0          88s

```

## Exercise 6.2: Using the Proxy

* Another way to interact with the API is via a proxy. The proxy can be run from a node or from within a Pod through the use of
a sidecar.
* 1. Begin by starting the proxy. It will start in the foreground by default. There are several options you could pass. Begin by
reviewing the help output.
* 2. Start the proxy while setting the API prefix, and put it in the background.

```bash
# kubectl proxy -h
Creates a proxy server or application-level gateway between localhost and the Kubernetes API Server.
It also allows serving static content over specified HTTP path. All incoming data enters through one
port and gets forwarded to the remote kubernetes API Server port, except for the path matching the
static content path.

Examples:
  # To proxy all of the kubernetes api and nothing else, use:

  $ kubectl proxy --api-prefix=/
......
# kubectl proxy --api-prefix=/ &
[1] 4555
Starting to serve on 127.0.0.1:8001

```

* 3. Now use the same curl command, but point toward the IP and port shown by the proxy. The output should be the same
as without the proxy.

```bash
# curl http://127.0.0.1:8001/api/
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "192.168.5.128:6443"
    }
  ]
}

```
* 4. Make an API call to retrieve the namespaces. The command did not work before due to permissions, but should work
now as the proxy is making the request on your behalf.

```bash
# curl  http://127.0.0.1:8001/api/v1/namespaces
{
  "kind": "NamespaceList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/namespaces",
    "resourceVersion": "19555736"
  },
  "items": [
    {
      "metadata": {
        "name": "default",
        "selfLink": "/api/v1/namespaces/default",
        "uid": "5378cbc5-81d4-11e9-a085-000c29f3984b",
        "resourceVersion": "145",
        "creationTimestamp": "2019-05-29T05:40:54Z"
      },
      "spec": {
......

```

## Exercise 6.3: Working with Cron Jobs
* We will create a simple cron job to explore how to create them and view their execution. We will run a regular job and view
both the job status as well as output. Note that the jobs are expected to be idempotent, so should not be used for tasks that
require strict timings to run.
* 1. Begin by creating a YAML for for the cron job. Set the time interval to be every minutes. Use the busybox container and pass it the date command.
* 2. Create the cron job.
* 3. Wait a few seconds for the job to ingested, then check that the job is active.
* 4. The first attempt at the job may fail, depending on when in the time configured it was created. Also note that the output
below shows that other jobs failed. Pass the –watch argument to view the jobs as they are created. Use ctrl-c to regain access to the shell.

```bash
vim cron-job.yaml
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: date
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: dateperminute
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; sleep 30
          restartPolicy: OnFailure
          
# kubectl create -f cron-job.yaml
cronjob.batch/date created
# kubectl get cronjobs.batch date
NAME   SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
date   */1 * * * *   False     1        13s             118s
 8s
# kubectl get cronjobs  date
NAME   SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
date   */1 * * * *   False     1        43s             2m28s
# kubectl get jobs --watch
NAME              COMPLETIONS   DURATION   AGE
date-1575525600   1/1           54s        2m56s
date-1575525660   1/1           52s        116s
date-1575525720   0/1           56s        56s
date-1575525720   1/1           58s        58s
date-1575525780   0/1                      0s
date-1575525780   0/1           0s         0s
^C
# kubectl logs date-1575600480-8jb4h
Fri Dec  6 02:48:24 UTC 2019
# kubectl delete cronjob date
cronjob.batch "date" deleted
```

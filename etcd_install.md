# etcd-install.md
## 部署ETCD集群
### 准备etcd软件包
```bash
cd /home/xiangxh/Kubernetes_v1.14.0
ETCD_VERSION=v3.3.13
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz -o etcd-${ETCD_VERSION}-linux-amd64.tar.gz
tar -xf etcd-v3.3.13-linux-amd64.tar.gz 
cd etcd-v3.3.13-linux-amd64
cp -v etcd etcdctl /opt/kubernetes/bin/ 
scp etcd etcdctl root@server02:/opt/kubernetes/bin/
scp etcd etcdctl root@server03:/opt/kubernetes/bin/
```
### 创建 etcd 证书签名请求
```bash
cd /home/xiangxh/Kubernetes_v1.14.0/create_ssl_dir
cat > etcd-csr.json << EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
"192.168.5.128",
"192.168.5.129",
"192.168.5.130"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "ShenZhen",
      "L": "ShenZhen",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
```
### 生成 etcd 证书和私钥
```bash
cd /home/xiangxh/Kubernetes_v1.14.0/create_ssl_dir
export PATH=/opt/kubernetes/bin:$PATH
cfssl gencert -ca=/opt/kubernetes/ssl/ca.pem \
  -ca-key=/opt/kubernetes/ssl/ca-key.pem \
  -config=/opt/kubernetes/ssl/ca-config.json \
  -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
ls -l etcd*
```
### 将证书复制到/opt/kubernetes/ssl目录下
```bash
cp -v etcd*.pem /opt/kubernetes/ssl
scp etcd*.pem root@server02:/opt/kubernetes/ssl
scp etcd*.pem root@server03:/opt/kubernetes/ssl
rm -f etcd.csr etcd-csr.json
```
### 创建ETCD配置文件脚本
```bash
mkdir /var/lib/etcd  # all node
cat > /opt/kubernetes/cfg/etcd.conf <<EOF
#[member]
ETCD_NAME="etcd-node1"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="https://192.168.5.128:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.5.128:2379,https://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.5.128:2380"
# if you use different ETCD_NAME (e.g. test),
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="etcd-node1=https://192.168.5.128:2380,etcd-node2=https://192.168.5.129:2380,etcd-node3=https://192.168.5.130:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.5.128:2379"
#[security]
CLIENT_CERT_AUTH="true"
ETCD_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_PEER_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
EOF
```
### 修改 server02 和server03 节点配置
```bash
# on server02
cat > /opt/kubernetes/cfg/etcd.conf <<EOF
#[member]
ETCD_NAME="etcd-node2"    #  modify
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="https://192.168.5.129:2380" #  modify
ETCD_LISTEN_CLIENT_URLS="https://192.168.5.129:2379,https://127.0.0.1:2379"  #  modify
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.5.129:2380" #  modify
# if you use different ETCD_NAME (e.g. test),
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="etcd-node1=https://192.168.5.128:2380,etcd-node2=https://192.168.5.129:2380,etcd-node3=https://192.168.5.130:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.5.129:2379" #  modify
#[security]
CLIENT_CERT_AUTH="true"
ETCD_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_PEER_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
EOF

# on server03
cat > /opt/kubernetes/cfg/etcd.conf <<EOF
#[member]
ETCD_NAME="etcd-node3"
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#ETCD_SNAPSHOT_COUNTER="10000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
ETCD_LISTEN_PEER_URLS="https://192.168.5.130:2380"
ETCD_LISTEN_CLIENT_URLS="https://192.168.5.130:2379,https://127.0.0.1:2379"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
#ETCD_CORS=""
#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.5.130:2380"
# if you use different ETCD_NAME (e.g. test),
# set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
ETCD_INITIAL_CLUSTER="etcd-node1=https://192.168.5.128:2380,etcd-node2=https://192.168.5.129:2380,etcd-node3=https://192.168.5.130:2380"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="k8s-etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.5.130:2379"
#[security]
CLIENT_CERT_AUTH="true"
ETCD_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_CA_FILE="/opt/kubernetes/ssl/ca.pem"
ETCD_PEER_CERT_FILE="/opt/kubernetes/ssl/etcd.pem"
ETCD_PEER_KEY_FILE="/opt/kubernetes/ssl/etcd-key.pem"
EOF

```
### 创建ETCD系统服务
```bash
cat > /etc/systemd/system/etcd.service<< EOF
[Unit]
Description=Etcd Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/etcd
EnvironmentFile=-/opt/kubernetes/cfg/etcd.conf
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /opt/kubernetes/bin/etcd"
Type=notify

[Install]
WantedBy=multi-user.target
EOF

for i in {02,03}; do scp /etc/systemd/system/etcd.service root@server$i:/etc/systemd/system/etcd.service
chmod +x /opt/kubernetes/bin/* 
```
### 重新加载系统服务
```bash
systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl status etcd
```

### 验证集群
```bash
export PATH=/opt/kubernetes/bin:$PATH
etcdctl --endpoints=https://192.168.5.128:2379 \
  --ca-file=/opt/kubernetes/ssl/ca.pem \
  --cert-file=/opt/kubernetes/ssl/etcd.pem \
  --key-file=/opt/kubernetes/ssl/etcd-key.pem cluster-health
member 20eeb8c2cd050ad is healthy: got healthy result from https://192.168.5.130:2379
member ab71cd512443aa51 is healthy: got healthy result from https://192.168.5.128:2379
member bed9dfd94ffd630b is healthy: got healthy result from https://192.168.5.129:2379
cluster is healthy

```

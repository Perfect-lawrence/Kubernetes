#!/bin/bash
# down_kubernetes package

#  download cfssl 
function dl_cfssl(){
echo -e "\033[35m Start download  cfssl-certinfo_linux-amd64 ....\033[0m"
curl -L  https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 -o /usr/local/bin/cfssl-certinfo
echo -e "\033[35m Start  download cfssl_linux-amd64 ....\033[0m"
curl -L  https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -o /usr/local/bin/cfssl
echo -e "\033[35m Start download cfssljson_linux-amd64 ....\033[0m"
curl -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 -o /usr/local/bin/cfssljson
chmod +x  /usr/local/bin/cfss*
ln -sv /usr/local/bin/cfssl-certinfo /usr/bin/cfssl-certinfo
ln -sv /usr/local/bin/cfssl /usr/bin/cfssl
ln -sv /usr/local/bin/cfssljson /usr/bin/cfssljson
}

function dl_etcd(){
ETCD_VER=v3.3.13
echo -e "\033[1;41;33m Start download etcd-${ETCD_VER}-linux-amd64.tar.gz ....\033[0m"
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o etcd-${ETCD_VER}-linux-amd64.tar.gz
}

function dl_flannel(){
FLANNEL_VER=v0.11.0
echo -e "\033[35m Start download /flannel-${FLANNEL_VER}-linux-amd64.tar.gz .....\033[0m"
curl -L https://github.com/coreos/flannel/releases/download/${FLANNEL_VER}/flannel-${FLANNEL_VER}-linux-amd64.tar.gz -o flannel-${FLANNEL_VER}-linux-amd64.tar.gz
}

function dl_docker(){
DOCKER_VER=18.06.3
# DOCKER_VER2=18.09.6
echo -e "\033[35m Start download  docker-${DOCKER_VER}-ce.tgz .....\033[0m"
curl -L https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER}-ce.tgz -o docker-${DOCKER_VER}-ce.tgz
# curl -L https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VER2}.tgz -o docker-${DOCKER_VER2}.tgz

}

function dl_docker-compose(){
DOCKER-COMPOSE_VER=1.24.0
echo -e "033\[35m Start download docker-compose ${DOCKER-COMPOSE_VER} ....\033[0m"
curl -L https://github.com/docker/compose/releases/download/${DOCKER-COMPOSE_VER}/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sv /usr/local/bin/docker-compose /usr/bin/docker-compose
}

function dl_kubernetes(){
K8S_VER=v1.14.0
# https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1142
# https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.14.md#v1140
echo -e "\033[47;30m Start download kubernetes.tar.gz ..... \033[0m"
curl -L https://dl.k8s.io/${K8S_VER}/kubernetes.tar.gz -o kubernetes.tar.gz

# Client Binaries
echo -e "\033[5;41;33m Start download kubernetes-client-linux-amd64.tar.gz ...\033[0m"
curl -L https://dl.k8s.io/${K8S_VER}/kubernetes-client-linux-amd64.tar.gz -o kubernetes-client-linux-amd64.tar.gz

# Server Binaries
echo -e "\033[31m Start download kubernetes-server-linux-amd64.tar.gz .....\033[0m"
curl -L https://dl.k8s.io/${K8S_VER}/kubernetes-server-linux-amd64.tar.gz -o kubernetes-server-linux-amd64.tar.gz

# Node Binaries
echo -e "\033[36m Start download kubernetes-node-linux-amd64.tar.gz ....\033[0m"
curl -L https://dl.k8s.io/${K8S_VER}/kubernetes-node-linux-amd64.tar.gz -o kubernetes-node-linux-amd64.tar.gz
}
case $i in
	cfssl)
		dl_cfssl
		;;
	etcd)
		dl_etcd
		;;
	docker)
		dl_docker
		;;
	docker-compose)
		dl_docker-compose
		;;
	flannel)
		dl_flannel
		;;
	k8s)
		dl_kubernetes
		;;
	*|--help)
	echo -e "\033[34m Usage: $0 {cfssl|etcd|docker|docker-compose|flannel|k8s}\033[0m"
		RETVAL=2
esac
exit $RETVAL

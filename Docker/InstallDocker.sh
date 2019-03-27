#!/bin/bash
# remove old docker
##sudo yum remove docker docker-common docker-selinux docker-engine

if [ ${UID} -eq 0 ]; then
# stop firewalld

systemctl stop firewalld
systemctl disable firewalld
sed -i 's/=enforcing/=disabled/' /etc/selinux/config
getenforce 

echo "Set hostname"
echo "docker.b0124.cn" > /etc/hostname 
hostnamectl set-hostname docker.b0124.cn
hostnamectl status
# setenforce 0 
# install docker				  
yum install -y yum-utils device-mapper-persistent-data lvm2
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
yum install -y docker-ce
yum list docker-ce --showduplicates | sort -r
systemctl start docker.service
systemctl enable docker.service
else
	echo "please use supper privileges users"
	exit 0
fi
curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
if [ $? -eq 0 ];
	chmod +x /usr/local/bin/docker-compose
	/usr/local/bin/docker-compose --version
fi

# echo "Configure docker registry for Aliyun docker registry"
echo "configure china docker registry "
cat > /etc/docker/daemon.json << EOF
{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF


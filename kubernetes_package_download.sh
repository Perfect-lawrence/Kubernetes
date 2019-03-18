#!/usr/bin/env bash
if [ ! -d ./k8s ]; then
	mkdir ./k8s
fi
if [ ! -f ./kubernetes_package.txt ]; then
	echo "no download url file" && exit 1
else
	wget --input-file=./kubernetes_package.txt --tries=3 --continue --timeout=30 --connect-timeout=15 --wait=15 --output-document=./k8s  --background --output-file=./k8s/download.log
fi

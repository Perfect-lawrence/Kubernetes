#!/bin/bash
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
kubectl create -f .
# 
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard-admin-token | awk '{print $1}')

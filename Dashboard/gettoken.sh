kubectl create -f .

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep kubernetes-dashboard-admin-token | awk '{print $1}')

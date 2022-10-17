#!/bin/bash


# Get token
TOKEN=$(kubectl -n kube-system get secrets monitoring-secret-token -ojsonpath='{.data.token}' | base64 -d)


APISERVER=$(kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")

# Get apiserver
curl -ks $APISERVER/metrics  --header "Authorization: Bearer $TOKEN" | grep -v "# " > apiserver.txt

# Get list of nodes of k3s cluster from api server and iterate over it
for i in `kubectl get nodes -o json | jq -r '.items[].status.addresses[0].address'`; do
  echo "Getting metrics from node $i"
  curl -ks https://$i:10250/metrics --header "Authorization: Bearer $TOKEN" | grep -v "# " > kubelet_$i.txt 
  curl -ks https://$i:10250/metrics/cadvisor --header "Authorization: Bearer $TOKEN" | grep -v "# " > kubelet_cadvisor_$i.txt
  curl -ks http://$i:10249/metrics | grep -v "# " > kubeproxy_$i.txt
done

# Get kube-controller and kube-scheduler

for i in `kubectl get nodes -o json | jq -r '.items[] | select(.metadata.labels."node-role.kubernetes.io/master" != null) | .status.addresses[0].address'`; do
  echo "Getting metrics from master node $i"
  curl -ks https://$i:10259/metrics --header "Authorization: Bearer $TOKEN" | grep -v "# " > kube-scheduler_$i.txt
  curl -ks https://$i:10257/metrics --header "Authorization: Bearer $TOKEN" | grep -v "# " > kube-controller_$i.txt
done


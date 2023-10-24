#!/bin/bash

# Создадим настроим мастер ноду при помощи kubeadm, для этого на ней выполним:
sudo kubeadm init --pod-network-cidr=10.129.0.14/16 --upload-certs --kubernetes-version=v1.23.0 --ignore-preflight-errors=Mem --cri-socket /run/containerd/containerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes

## Установим сетевой плагин
# В этом ДЗ в качестве примера мы установим Flannel, Вы можете установить, любой другой.
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
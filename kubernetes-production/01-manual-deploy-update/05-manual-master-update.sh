#!/bin/bash

# Обновим kubeadm на мастер ноде
sudo apt update
sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm=1.24.17-00 && sudo apt-mark hold kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.24.17
# Обновим kubelet and kubectl на master-ноде
sudo apt update
sudo apt-cache madison kubelet
sudo apt-cache madison kubectl
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet=1.24.17-00 && sudo apt-get install -y kubectl=1.24.17-00 && sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet
# Проверка
kubeadm version
kubelet --version
kubectl version
kubectl describe pod kube-apiserver-master -n kube-system

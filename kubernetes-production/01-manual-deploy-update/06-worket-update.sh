# ВЫПОЛНИТЬ НА MASTER НОДЕ - Вывод worker-ноды из планирования
kubectl drain worker-XX --ignore-daemonsets
kubectl get nodes -o wide

# на worker-ноде выполняем
sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm=1.24.17-00 && sudo apt-mark hold kubeadm
sudo kubeadm upgrade node
sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet=1.24.17-00 && sudo apt-get install -y kubectl=1.24.17-00 && sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# ВЫПОЛНИТЬ НА MASTER НОДЕ - Возвращение worker-ноды в планирование
kubectl uncordon worker-XX
kubectl get nodes -o wide

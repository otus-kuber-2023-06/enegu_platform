#!/bin/bash

sudo kubeadm join 10.129.0.14:6443 --token hs0ux7.xxxxxx \
	--discovery-token-ca-cert-hash sha256:a64906582973f37ee2a81a4ea31c1d62c06fd65c1889aafb03eb7753752ebf61
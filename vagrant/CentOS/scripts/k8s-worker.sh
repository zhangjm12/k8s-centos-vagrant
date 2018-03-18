#!/bin/bash

IPADDR=$1
TOKEN=$2
NODEIP=$3

if [ ! -e /etc/kubernetes/kubelet.conf ]; then
    echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${NODEIP}\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    systemctl daemon-reload
    systemctl restart kubelet

    echo kubeadm join --token ${TOKEN} --discovery-token-unsafe-skip-ca-verification ${IPADDR}:6443
    kubeadm join --token ${TOKEN} --discovery-token-unsafe-skip-ca-verification ${IPADDR}:6443

    mkdir -p $HOME/.kube
    /bin/cp -f /vagrant/.kube/config $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    while kubectl get nodes | grep $(hostname) | grep NotReady >/dev/null;
    do
        echo $(date +"[%H:%M:%S]") Worker $(hostname) is not ready yet
        sleep 10
    done

    echo $(date +"[%H:%M:%S]") Worker $(hostname) is in Ready mode
fi

kubectl get nodes

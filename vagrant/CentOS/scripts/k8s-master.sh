#!/bin/bash

IPADDR=$1
TOKEN=$2

# yum install -y etcd

if [ ! -e /etc/kubernetes/kubelet.conf ]; then
    echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${IPADDR}\"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    systemctl daemon-reload
    systemctl restart kubelet

    echo kubeadm init --apiserver-advertise-address ${IPADDR} --token ${TOKEN} --pod-network-cidr 10.244.0.0/16 --service-cidr=10.243.0.0/16
    kubeadm init \
        --pod-network-cidr 10.244.0.0/16 \
        --service-cidr=10.243.0.0/16 \
        --apiserver-advertise-address ${IPADDR} \
        --token ${TOKEN}

    mkdir -p $HOME/.kube
    /bin/cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    rm -rf /vagrant/.kube
    /bin/cp -rf $HOME/.kube /vagrant/.kube

    # Installing a Pod Network
    # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
    # https://github.com/coreos/flannel/blob/master/Documentation/troubleshooting.md#vagrant
    kubectl apply -f /vagrant/configs/kube-flannel.yaml

    # Wait until Master is Up
    while kubectl get nodes | grep master | grep NotReady >/dev/null;
    do
        echo $(date +"[%H:%M:%S]") Master is not ready yet
        sleep 10
    done

    echo $(date +"[%H:%M:%S]") Master is in Ready mode
fi

kubectl get nodes

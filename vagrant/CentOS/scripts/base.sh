#!/bin/bash

export https_proxy=http://10.100.17.37:80
export no_proxy=192.168.12.218,192.168.12.224,192.168.12.22,192.168.12.222,192.168.11.251

yum install -y deltarpm

# echo "Updating System"
# yum update -y

# yum install -y nss-mdns avahi avahi-tools
# systemctl enable avahi-daemon
# systemctl start avahi-daemon

echo "Disabling SELINUX"
getenforce | grep Disabled || setenforce 0
# sed -i 's/\(SELINUX=\).*/\1=disabled/' /etc/sysconfig/selinux
echo "SELINUX=disabled" > /etc/sysconfig/selinux

echo "Installing EPEL REPO and tools"
yum install -y epel-release
yum install -y wget ntp jq net-tools bind-utils

systemctl start ntpd
systemctl enable ntpd

# install docker-ce
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

cat <<EOF > /etc/sysconfig/docker
HTTPS_PROXY=http://10.100.17.37:80
NO_PROXY=192.168.12.218,192.168.12.224,192.168.12.22,192.168.12.222,192.168.11.251
EOF

mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "insecure-registries":["10.0.0.0/8"]
}
EOF

sed -i "s/\[Service\]/\[Service\]\nEnvironmentFile=-\/etc\/sysconfig\/docker/g" /lib/systemd/system/docker.service

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
# https://kubernetes.io/docs/setup/independent/install-kubeadm/
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo "Installing Docker and Kubernetes"
yum install -y kubelet kubeadm kubectl

sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sed -e '/KUBELET_CADVISOR_ARGS=/ s/^#*/#/' -i /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sed -i "s/10.96.0.10/10.243.0.10/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

systemctl daemon-reload
systemctl start docker
systemctl enable docker 
systemctl enable kubelet

# Disable SWAP (As of release Kubernetes 1.8.0, kubelet will not work with enabled swap.)
echo "Disabling SWAP"
sed -i 's/[^#]\(.*swap.*\)/# \1/' /etc/fstab
swapoff --all


# yum install -y dnsmasq
# cat <<EOF > /etc/dnsmasq.d/10-kub-dns
# server=/svc.cluster.local/10.96.0.10#53
# listen-address=127.0.0.1
# bind-interfaces
# EOF

# systemctl start dnsmasq
# systemctl enable dnsmasq

unset https_proxy no_proxy

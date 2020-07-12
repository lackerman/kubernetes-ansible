#!/bin/bash

exists() {
  command -v "$1" >/dev/null 2>&1
}

if exists kubeadm; then
    kubeadm reset
    iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
fi

if exists k3s && exists k3s-killall.sh; then
    /usr/local/bin/k3s-killall.sh
    /usr/local/bin/k3s-uninstall.sh
fi

rm -rf \
    /etc/systemd/system/k3s* \
    /etc/systemd/system/multi-user.target.wants/k3s* \
    /etc/rancher \
    /etc/kubernetes \
    /usr/local/bin/kubectl \
    /usr/local/bin/crictl \
    /usr/local/bin/ctr \
    /usr/local/bin/k3s* \
    /usr/local/bin/kxs* \
    /var/lib/etcd \
    /var/lib/rancher \
    /var/log/containers \
    /var/log/pods \
    /tmp/k3s.* \
    /tmp/k3s.* \
    /home/${SUDO_USER}/.kube \
    /root/.kube \
    /run/k3s

# Make sure to stop the service and reload the systemd daemon
systemctl stop k3s-agent.service
systemctl daemon-reload
systemctl reset-failed

# Manual kubernetes deployment
    # kubeadm init --kubernetes-version=1.16.0 --pod-network-cidr=10.244.0.0/16
    # mkdir ${HOME}/.kube
    # cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
    # chown $(id -u):$(id -g) ${HOME}/.kube/config
    # kubectl apply -f \
        https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    # systemctl enable docker
    # systemctl enable kubelet

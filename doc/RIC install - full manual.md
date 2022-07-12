# Installing the virtual machine
## Get the image
~~~bash
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
~~~
## Preparing the disk image
~~~bash
qemu-img create -f qcow2 -F qcow2 -b bionic-server-cloudimg-amd64.img ric.qcow2 50G
~~~
## Preparing the cloud image file for installation
~~~bash
cat << EOF > ric.yml
cloud-config
ssh_pwauth: true
disable_root: true

users:
  - name: rick
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users,admin
    home: /home/rick
    shell: /bin/bash
    lock_passwd: false

chpasswd:
  list: |
    rick:linux

hostname: ric
fqdn: ric.lan

growpart:
  mode: auto
  devices:
    - '/'

package_update: true
packages:
  - qemu-guest-agent
  - git
  - linux-image-4.15.0-45-lowlatency
EOF
~~~
~~~bash
cat << EOF > ric-net.yml
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses: [ 192.168.2.41/24 ]
    gateway4: 192.168.2.1
    nameservers: 
      addresses: [ 192.168.2.21, 192.168.0.1 ]
EOF
~~~
~~~bash
cloud-localds -v --network-config=ric-net.yml ric-cloud-init.img ric.yml
~~~
## Installing the virtual machine
~~~bash
virt-install --name ric --vcpus 4 --memory 8192 \
	--disk path=ric.qcow2,device=disk --import  \
	--disk path=ric-cloud-init.img,device=cdrom \
	--os-variant=ubuntu18.04                    \
	--network network=ricnet                    \
	--graphics vnc,listen=0.0.0.0
~~~
- To accompany the installation process, use `virsh console <name>` like `virsh console ric`.
- Once the installation finishes, connect to the machine - `ssh rick@192.168.2.41` - with password `linux`. You'll be propted to change the password. The next steps are executed in the virtual machine just created.
## Download the RIC distribution
~~~bash
git clone https://gerrit.o-ran-sc.org/r/it/dep /ric
git checkout 397cc164dbbee967d227df897859e55ac807349f
git submodule update -i
~~~
## Setup the host
~~~bash
modprobe ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 nf_conntrack_ipv6 nf_conntrack_proto_sctp

for mod in ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh nf_conntrack_ipv4 nf_conntrack_ipv6 nf_conntrack_proto_sctp ; do
	echo $mod >> /etc/modules-load.d/ric.conf
done
~~~
## Install kubernetes
~~~bash
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install --allow-downgrades --allow-change-held-packages \
	--allow-unauthenticated --ignore-hold -y virt-what curl jq \
	netcat make ipset moreutils linux-image-4.15.0-45-lowlatency \
	docker.io kubernetes-cni=0.7.5-00 kubeadm=1.16.0-00 \
	kubelet=1.16.0-00 kubectl=1.16.0-00
apt-mark hold docker.io kubernetes-cni kubelet kubeadm kubectl
~~~
## Configure docker
~~~bash
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
~~~
~~~bash
systemctl enable docker
systemctl restart docker
~~~
- If docker fails to restart, check `/etc/docker/daemon.json` for errors.
## Configure k8s
~~~bash
cat <<EOF >/root/config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kubernetesVersion: v${KUBEV}
kind: ClusterConfiguration
apiServer:
  extraArgs:
    feature-gates: SCTPSupport=true
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF
~~~
~~~bash
cat <<EOF > /root/rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF
~~~
~~~bash
kubeadm config images pull --kubernetes-version=1.16.0
kubeadm init --config /root/config.yaml
cd /root
mkdir -p .kube
ln -sf /etc/kubernetes/admin.conf /root/.kube/config
export KUBECONFIG=/root/.kube/config
echo "KUBECONFIG=${KUBECONFIG}" >> /etc/environment
kubectl apply -f "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
kubectl label --overwrite nodes ric local-storage=enable
mkdir -p /opt/data/dashboard-data
~~~
- After this, `kubectl get pods -A` should show something similar to this output
~~~bash
kubectl get pods -A
NAMESPACE     NAME                          READY   STATUS    RESTARTS   AGE
kube-system   coredns-5644d7b6d9-rqb9g      1/1     Running   0          62m
kube-system   coredns-5644d7b6d9-rrs2g      1/1     Running   0          62m
kube-system   etcd-ric                      1/1     Running   0          61m
kube-system   kube-apiserver-ric            1/1     Running   0          61m
kube-system   kube-controller-manager-ric   1/1     Running   0          61m
kube-system   kube-flannel-ds-z2pp2         1/1     Running   0          2m8s
kube-system   kube-proxy-2kbnp              1/1     Running   0          62m
kube-system   kube-scheduler-ric            1/1     Running   0          61m
~~~
## Install helm
~~~bash
wget https://get.helm.sh/helm-v3.2.3-linux-amd64.tar.gz
tar xf helm-v3.2.3-linux-amd64.tar.gz -C /tmp
cp /tmp/linux-amd64/helm /usr/local/bin/
~~~
## Setup nfs storage (TODO)
~~~bash

~~~
- From here, RIC can be deployed via scripts or manually.

##  Installing RIC (automated)
~~~bash
cd /ric/bin
cp ../RECIPE_EXAMPLE/PLATFORM/example_recipe_oran_e_release.yaml .
~~~
- Edit `example_oran_e_release.yml` to reflect the expected ip addresses.
~~~bash
./deploy-ric-platform -f example_recipe_oran_e_release.yaml
~~~
## Installing RIC (manual)
- Install and start `servecm` plugin
~~~bash
helm plugin install https://github.com/jdolitsky/helm-servecm
mkdir -p /home/rick/.cache/helm/repository/local
helm servecm --port=8879 --context-path=/charts --storage local --storage-local-rootdir /home/rick/.cache/helm/repository/local
~~~
- Create the base charts
~~~bash
helm package -d /tmp /ric/ric-common/Common-Template/helm/ric-common/
cp /tmp/ric-common-3.3.2.tgz /home/rick/.cache/helm/repository/local

helm package -d /tmp /ric/ric-common/Common-Template/helm/aux-common/
cp /tmp/aux-common-3.0.0.tgz /home/rick/.cache/helm/repository/local

helm package -d /tmp /ric/ric-common/Common-Template/helm/nonrtric-common/
cp /tmp/nonrtric-common-2.0.0.tgz /home/rick/.cache/helm/repository/local

helm repo index /home/rick/.cache/helm/repository/local
helm repo add local http://127.0.0.1:8879/charts
~~~
- Create the namesapces
~~~bash
kubectl create ns ricplt
kubectl create ns ricinfra
kubectl create ns ricxap
~~~
- Create the config map
~~~bash
kubectl create configmap -n ricplt ricplt-recipe --from-file=recipe=example_recipe_oran_e_release.yaml
~~~
# Automating
[Ansible](https://buildvirtual.net/deploy-a-kubernetes-cluster-using-ansible/), [Vagrant](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/),[kubespray.io](https://kubespray.io/#/)

- [kubernetes.core](https://galaxy.ansible.com/kubernetes/core) supports kubernetes `1.19`. O-RAN supports kubernetes `1.16`.
- The ansible version in ubuntu 18.04 does not support collections, so automation is just repeating the steps above in an ansible script. Some of the steps will have builtin idempotence, but some will not; the script doesn't allow for maintenance of the system.
- Possibly changing the version of ubuntu to a more recent

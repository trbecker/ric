# Host preparation
- Add a bridge to the host
~~~bash
apt install bridge-utils

~~~
- Partial netplan configuration
~~~yaml
  bridges:      
    my5g: 
      dhcp4: no
      interfaces:
        - eno1
      addresses: [ 10.100.128.1/16 ]
      nameservers:
        search: [ pipca.unisinos.br ]
        addresses:
          - "10.0.0.1"
~~~

# `virsh` preparation
- Create the cloud-init file
~~~bash
cat << EOF > ric.yml
#cloud-config
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

power_state:
  mode: reboot
EOF
~~~
- Create the network cloud-config file
~~~bash
cat << EOF > ric-net.sh
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
- Creante the cloud config file
~~~bash
cloud-localds -v --network-config=ric-net.yml ric-seed.img ric.yml
~~~
- Create the disk image
~~~
qemu-img create -f qcow2 -F qcow2 -b /pool/bionic.qcow2 /pool/ric.qcow2 50G
~~~
- Create the virtual machine
~~~bash
virt-install --name ric \
	--memory 6144 --vcpus 2 \
	--disk path=ric-seed.img,device=cdrom \
	--disk path=ric.qcow2,device=disk --import \
	--os-variant=ubuntu18.04 \
	--network network=<net> \
	--graphics vnc,listen=0.0.0.0
~~~
# Installing the infrastructure
- Machine is installed and ssh is accessible.
- git is installed.
- Clone the dep repository
~~~bash
git clone https://gerrit.o-ran-sc.org/r/it/dep /ric
cd /ric
git submodule update -i
~~~
- Edit the configuration to use `helm3`
~~~bash
vim tools/k8s/etc/infra.rc
# uncomment this line
INFRA_HELM_VERSION="3.2.3"
# comment this line
#INFRA_HELM_VERSION="2.17.0"
~~~
- Create the installation script
~~~bash
cd tools/k8s/bin/
./gen-cloud-init.sh
./k8s-1node-cloud-init-k_1_16-h_3_2-d_cur.sh
cd /ric
~~~
- The machine will reboot
- Tested with revision `5288913d914df119819fd349c57eb3ace44a423c`
# Deploying the RIC
~~~bash
cd /ric/bin
cp ../RECIPE_EXAMPLE/PLATFORM/example_recipe_oran_e_release.yaml .
~~~
- Set the correct IP addresses in the recipe.
~~~bash
vim example_recipe_oran_e_release.yaml
# change these lines
extsvcplt:
  ricip: "192.168.2.42"
  auxip: "192.168.2.43"
~~~
- Deploy the RIC
~~~
./deploy-ric-platform example_recipe_oran_e_release.yaml
~~~

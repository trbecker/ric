#!/bin/bash

# Quickly starts the installation of the ric and aux virtual machines
# This script is designed to be used during testing the installation, but can be used outside it.

function install_vm {
    virsh destroy $1
    virsh undefine $1
    /bin/rm /pool/$1.qcow2
    qemu-img create -f qcow2 -F qcow2 -b /pool/bionic.qcow2 /pool/$1.qcow2 20G
    virt-install --name $1                                         \
        --cloud-init user-data=cloud-init/bionic/$1.yml,disable=on \
        --memory 6144 --vcpus 2                                    \
        --disk path=/pool/$1.qcow2 --import                        \
        --os-variant=ubuntu18.04                                   \
        --network network=ricnet                                   \
        --graphics vnc,listen=0.0.0.0
}

install_vm ric 2>&1 > /tmp/ric-install.txt &
install_vm aux 2>&1 > /tmp/aux-install.txt &

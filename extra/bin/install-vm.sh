#!/bin/bash

CUR=$(dirname $(readlink -f $0))
source $CUR/env

virsh destroy $2
virsh undefine $2
rm -fr $STORAGE_DIR/$2.qcow2

qemu-img create -f qcow2 -F qcow2 -b $STORAGE_DIR/$1.qcow2 $STORAGE_DIR/$2.qcow2 20G
$CUR/create-cloud-init.sh $1 $2

virt-install --name $1                                         \
    --memory 6144 --vcpus 2                                    \
    --disk path=$STORAGE_DIR/$2-seed.img,device=cdrom          \
    --disk path=$STORAGE_DIR/$2.qcow2,device=disk --import     \
    --os-variant=ubuntu18.04                                   \
    --network network=ricnet                                   \
    --graphics vnc,listen=0.0.0.0

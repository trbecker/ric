#!/bin/bash

CUR=$(dirname $(readlink -f $0))
source ${CUR}/env

RELEASE_DIR=${CUR}/../../cloud-init/$1/

cloud-localds -v --network-config=${RELEASE_DIR}/net-${2}.yml \
                 ${STORAGE_DIR}/${2}-seed.img \
                 ${RELEASE_DIR}/${2}.yml

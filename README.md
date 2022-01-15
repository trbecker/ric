# Ran Intelligent Controller

## Deploying a RIC virtual machine with [cloud-init](https://cloud-init.io/)

### Pre-reqs
A virtual machine host with the following packages:
  * [Fedora](https://getfedora.org/)

        dnf install -y cloud-utils libguestfs-tools-c virt-install libvirt-client libvirt


  * [Ubuntu](https://ubuntu.com/) (TBD)

### Installing

  1. Obtain a `qcow2` image at [Ubuntu cloud images](https://cloud-images.ubuntu.com/).
  2. Resize the image.
    
         qemu-img resize <image> 200G
    
  3. Create the virtual machine
    
         virt-install --name ric                                           \
             --cloud-init user-data=cloud-init/ric-xenial.yml              \
             --memory=12288 --vcpus 4                                      \
             --disk path=<image> --import                                  \
             --os-variant detect=on                                        \
             --network default                                             \
             --graphics vnc,listen=0.0.0.0

  4. The machine will be ready to create the [kubernetes](https://kubernetes.io/) cluster. The RIC [dep](https://gerrit.o-ran-sc.org/r/admin/repos/it/dep) repository will be installed in `/ric`.

## Future Steps
  * Create the kubernetes cluster.

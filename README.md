# RAN Intelligent Controller

## Deploying a RIC virtual machine with [cloud-init](https://cloud-init.io/)

### Pre-reqs
A virtual machine host with the following packages ([reference documentation](https://docs.o-ran-sc.org/projects/o-ran-sc-it-dep/en/latest/installation-guides.html#virtualbox-vms-as-installation-hosts)):
  * Operationg system and packages
    * [Fedora](https://getfedora.org/)

          dnf install -y cloud-utils libguestfs-tools-c virt-install libvirt-client libvirt

      These packages are provisioned by the ansible playbook provided in the host directory.

    * [Ubuntu](https://ubuntu.com/) (TBD)

  * The network `ricnet` defined as documented in the reference (Ansible provisions it).

        <network>
          <name>ricnet</name>
          <forward mode='nat'/>
          <bridge name='ricbr' stp='on' delay='0'/>
          <mac address='52:54:00:10:86:a4'/>
          <ip address='192.168.123.1' netmask='255.255.255.0'>
            <dhcp>
              <range start='192.168.123.2' end='192.168.123.99'/>
            </dhcp>
          </ip>
        </network>

  * Port forwarding as defined in the documentation.

        firewall-cmd --add-forward-port=port=22222:proto=tcp:toport=22:toaddr=192.168.123.100
        firewall-cmd --add-forward-port=port=22222:proto=tcp:toport=22:toaddr=192.168.123.100 --permanent
        firewall-cmd --add-forward-port=port=22223:proto=tcp:toport=22:toaddr=192.168.123.101
        firewall-cmd --add-forward-port=port=22223:proto=tcp:toport=22:toaddr=192.168.123.101 --permanent
        firewall-cmd --add-forward-port=port=22224:proto=tcp:toport=32080:toaddr=192.168.123.100
        firewall-cmd --add-forward-port=port=22224:proto=tcp:toport=32080:toaddr=192.168.123.100 --permanent
        firewall-cmd --add-forward-port=port=22225:proto=tcp:toport=32080:toaddr=192.168.123.101
        firewall-cmd --add-forward-port=port=22225:proto=tcp:toport=32080:toaddr=192.168.123.101 --permanent

### Installing

  1. Obtain a `qcow2` image at [Ubuntu cloud images](https://cloud-images.ubuntu.com/). The recommended version is Ubuntu 18.04 (Bionic Beaver).
  2. Resize the image.
    
         qemu-img resize <image> 20G
	 
  3. Create the image
    
         qemu-img create -f qcow2 -F qcow2 -b <image> ric.qcow2 20G
    
  4. Create the virtual machine
    
         virt-install --name ric                                           \
             --cloud-init user-data=cloud-init/bionic/ric.yml,disable=on   \
             --memory=6144 --vcpus 2                                       \
             --disk path=ric.qcow2 --import                                \
             --os-variant detect=ubuntu18.04                               \
             --network network=ricnet                                      \
             --graphics vnc,listen=0.0.0.0

  5. The machine will be ready to create the [kubernetes](https://kubernetes.io/) cluster. The RIC [dep](https://gerrit.o-ran-sc.org/r/admin/repos/it/dep) repository will be installed in `/ric`.

## Issues
  * Currently, cloud init is not setting the correct IP address for each machine.
  * The cloud-init files reboot after running the RIC setup
  * The default kernel neds to be set manually for bionic

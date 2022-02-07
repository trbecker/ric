# RAN Intelligent Controller

## Deploying a RIC virtual machine with [cloud-init](https://cloud-init.io/)

### Pre-reqs
**Note**: Fedora can be auto configured by following the instructions in [host/README.md](host/README.md).

A virtual machine host with the following packages ([reference documentation](https://docs.o-ran-sc.org/projects/o-ran-sc-it-dep/en/latest/installation-guides.html#virtualbox-vms-as-installation-hosts)):
  * Operationg system and packages
    * [Fedora](https://getfedora.org/)

          dnf install -y cloud-utils libguestfs-tools-c virt-install libvirt-client libvirt

      These packages are provisioned by the ansible playbook provided in the host directory.

    * [Ubuntu](https://ubuntu.com/) (TBD)

  * The network `ricnet` defined as documented in the reference.

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

  1. Obtain a `qcow2` image at [Ubuntu cloud images](https://cloud-images.ubuntu.com/). The recommended version is Ubuntu 18.04 (Bionic Beaver). Some ubuntu images don't use `.qcow2` as the termination, e.g. `bionic-server-cloudimg-amd64.img`.

  2. To quickly install the virtual machine, the operator can use the command below. Otheriwse the same script can be used to create the virtual machine.
     ~~~
     extra/bin/install-vm.sh bionic ric
     ~~~
     

## Post install
### Install the infrastructure for xApps
  1. Follow the steps in [RIC installation guide](https://docs.o-ran-sc.org/projects/o-ran-sc-it-dep/en/latest/installation-guides.html)

## Issues
  * Currently, cloud init is not setting the correct IP address for each machine.
  * The cloud-init files reboot after running the RIC setup
  * The default kernel neds to be set manually for bionic

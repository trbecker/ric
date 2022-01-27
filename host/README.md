 # Virtual Machine Host for RAN Intelligent Controller Testing

This directory provides examples of how to setup a virtual machine hosts for developing and testing RAN Intelligent Controllers. The documentation for intallation can be found on the [O-RAN-SC community wiki](https://docs.o-ran-sc.org/projects/o-ran-sc-it-dep/en/latest/installation-guides.html#virtualbox-vms-as-installation-hosts)

## Stand alone installation
The standalone installation is intended for machines that are not port of an [Ansible](https://ansible.com) managed infrastructure. It uses ansible. 

### Pre requisites

  1. Install packages

         sudo dnf install -y ansible git
	 
  2. Clone this repository
      
  3. Install the ansible collections

         sudo ansible-galaxy collection install -r requirements.yml

### Configuring the host
Before configuring, copy `vars.yml.example` to `vars.yml` and change the values to reflect your environment.

To configure the host, run

    sudo ansible-playbook -i standalone_hosts standalone.yml

Once the host is configured, the latest ubuntu bionic image can be found in the directory configured in `vars.yml`.


**Note**: ansible.posix.firewalld has an issue in Fedora 35. You may need to set the port forwarding mannually.

    firewall-cmd --add-forward-port=port=22222:proto=tcp:toport=22:toaddr=192.168.123.100
    firewall-cmd --add-forward-port=port=22222:proto=tcp:toport=22:toaddr=192.168.123.100 --permanent
    firewall-cmd --add-forward-port=port=22223:proto=tcp:toport=22:toaddr=192.168.123.101
    firewall-cmd --add-forward-port=port=22223:proto=tcp:toport=22:toaddr=192.168.123.101 --permanent
    firewall-cmd --add-forward-port=port=22224:proto=tcp:toport=32080:toaddr=192.168.123.100
    firewall-cmd --add-forward-port=port=22224:proto=tcp:toport=32080:toaddr=192.168.123.100 --permanent
    firewall-cmd --add-forward-port=port=22225:proto=tcp:toport=32080:toaddr=192.168.123.101
    firewall-cmd --add-forward-port=port=22225:proto=tcp:toport=32080:toaddr=192.168.123.101 --permanent

# Future work
- Convert the stand alone script into a role

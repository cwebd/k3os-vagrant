# k3OS on Vagrant

Vagrant setup allowing for single and multi server and agent configuration. Full configuration of the k3os configuration file with .vagrantuser server configuration. Provisioning handles the configuration updates with server restarting.

The default configuration uses wireguard ensuring all node communication is encrypted.

## Prerequisites

    - Vagrant
    - libvrt plugin
    CONFIGURE_ARGS="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib" vagrant plugin install vagrant-libvirt
    - Setup Bridge Networking (Example for Ubuntu 20.04LTS)
    This will allow the host and guest to be able to communicate
    cp scripts/macvlan /etc/init.d/macvlan
    chmod u+x /etc/init.d/macvlan
    Edit /etc/init.d/macvlan if your eth0 interface is not the default, update HWLINK
    cp scripts/macvlan.service to /etc/systemd/system/macvlan.service
    systemctl enable macvlan.service
    systemctl start macvlan.service

## Quick Start

`$>cp .vagrantuser.example .vagrantuser`

Update the ip address to an address which can bridge your current network, to generate a mac address:

`$>printf '%02x' $((0x$(od /dev/urandom -N1 -t x1 -An | cut -c 2-) & 0xFE | 0x02)); od /dev/urandom -N5 -t x1 -An | sed 's/ /:/g'`

Update your networking DHCP lease to assign the ip address.

`$>cp config.yaml.example config.yaml`
`$>vagrant up`

This will create a single k3os instance running k3s in master mode. To connect:

`$>vagrant ssh`

Retrieve the configuration from /etc/rancher/k3s/k3s.yaml

Update the server url to a server ip address as configured in config.yaml

Update your local .kube/config with the contents of the k3s configuration file with the updated ip address.

On your local system:

`$>kubectl get nodes`

This should then deliver one k3os master server available.

## Multi server and agent setup with k3os configuration

By default there is a single config.yaml file which is used by all the servers/agents, this config.yaml file includes variables which are dynamically replaced on provisioning by values set in .vagrantuser k3os_config_env.

New values can be created and used as variables within the config.yaml.

A single config.yaml can be used for all the servers/agents or separated by defining the k3os_config value to the configuration path.

When creating a multi server architecture use the server name to connect:

`$>vagrant ssh server1`

When using libvrt the virtual machine machine can be used to access and review the boxes.

When adding multiple servers to avoid a race condition bring up server1 first and ensure that this is online, then add additional servers individually into the cluster until at the desired amount.

## Updating k3os configuration information

When the .vagrantuser k3os configuration is updated, run:

`$>vagrant provision`

This will then deploy the new configuration, the provision scripts compare if the k3os config yaml matches the system k3os config yaml, if there are differences this file is copied across and the box is restarted so that the changes take effect.

## Building Packer boxes

As packer will build both kvm and virtualbox images ensure that libvrt boxes are shut down and not running as Virtualbox and KVM will not work concurrently.

`$>cd packer`
`$>./cleanup.sh`
`$>./build.sh`

This will produce a libvrt and virtualbox .box to upload to vagrant cloud

## Debugging the vagrant provision

If provision_debug is set to true in the .vagrantuser then the provision scripts will not be removed from /home/rancher.

## Notes

 - The Virtualbox guest additions are not installed

## References

 - K3os https://github.com/rancher/k3os
 - Vagrant https://www.vagrantup.com/
 - Vagrant Cloud https://app.vagrantup.com/
 - Modified from https://github.com/rancher/k3os/blob/master/LICENSE

## Similar project

https://github.com/wjimenez5271/k3os-vagrant

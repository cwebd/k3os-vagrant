# k3OS on Vagrant

Multi node cluster setup allowing for configuration via nugrant in vagrant.

## Quick Start

`$>vagrant up`

This will create a single k3os instance running k3s in master mode. To connect:

`$>vagrant ssh`

Retrieve the configuration from /etc/rancher/.... [TODO]

`$>ifconfig | grep eth0`

Get the ip address of the instance.

Update your local .kube/config with the contents of the k3s configuration file with the updated ip address.

On your local system:

`$>kubectl get nodes`

Should then deliver one k3os master server available.

## Multi Instance setup

TODO

## Building Packer boxes

`$>cd packer`
`$>./cleanup.sh`
`$>./build.sh`

This will produce a libvrt and virtualbox .box to upload to vagrant cloud

## Notes

The Virtualbox guest additions are not installed

## References

 - K3os https://github.com/rancher/k3os
 - Vagrant https://www.vagrantup.com/
 - Vagrant Cloud https://app.vagrantup.com/
 - Modified from https://github.com/rancher/k3os/blob/master/LICENSE
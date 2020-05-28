- Add multi server configuration using .vagrantuser
- K3os configuration provisioning

1.0.1
 - Update README
 - k3os v0.10.1-rc1-1-g4e7da23-amd64
 - Add libvrt provisioner
 - Move packer to a separate directory and bring in the configuration for a multi node configuration
 - Add vagrantfile.template to add configure_networks for Linux and nugrant

1.0.0

 - K3os 0.9.1
 - Increase boot wait to 20 seconds
 - Set virtual machine to 1024MB memory rather than 512MB which was swapping.
 - Remove echo command in vagrant shell provisioner
 - Cloud config boot_cmd Set password authentication to yes if the vagrant key isn't present
 - Add vagrant provisioner script to set ssh password authentication off once the public vagrant ssh key has been added.
 - Add cleanup.sh script to remove packer artifacts before building
 - README instructions for packer build to include on-error abort

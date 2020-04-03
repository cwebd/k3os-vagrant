0.1.0

 - K3os 0.9.1
 - Increase boot wait to 20 seconds
 - Set virtual machine to 1024MB memory rather than 512MB which was swapping.
 - Remove echo command in vagrant shell provisioner
 - Cloud config boot_cmd Set password authentication to yes if the vagrant key isn't present
 - Add vagrant provisioner script to set ssh password authentication off once the public vagrant ssh key has been added.
 - Add cleanup.sh script to remove packer artifacts before building
 - README instructions for packer build to include on-error abort
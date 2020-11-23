# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.user.defaults = {
    'bridge_interface' => '',
    'box' => 'cwebd/k3os',
    'box_version' => '',
    # Specify a box url to override the box from vagrant cloud
    'box_url' => '',
    'ssh_username' => 'rancher',
    # Provider can be libvirt or virtualbox, set virtualbox as the default for compatibility
    'provider' => 'virtualbox',
    'driver' => 'kvm',
    'keymap' => 'en-gb',
    'provision_debug' => false,
    'servers' => {
      'server1' => {
        'macaddress2' => '',
        'k3os_config' => '',
        'k3os_config_env' => {
        },
        'cpus' =>  1,
        'memory' =>  1024,
      }
    }
  }

  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  # Override with the user configuration if present
  # This sets the default provider, boxes can also override the provider
  if config.user.provider != ""
    provider = config.user.provider
  end

  config.ssh.username = config.user.ssh_username

  config.vm.box = config.user.box
  config.vm.box_check_update = true
  config.vm.guest = :linux

  bridge_interface = config.user.bridge_interface

  # If a box_url is provided then the version cannot be passed across
  if config.user.box_url != ''
    config.vm.box_url = config.user.box_url
  else
    if config.user.box_version != ''
      config.vm.box_version =  config.user.box_version
    end
  end

  config.user.servers.each do |server, server_config|

    config.vm.define server do |cfg|

      if provider == 'libvrt'

        cfg.vm.provider :libvirt do |vm, override|
          vm.management_network_mode = "route"
          vm.driver = config.user.driver
          vm.cpus = server_config[:cpus]
          vm.memory = server_config[:memory]
          vm.keymap = config.user.keymap
          vm.storage :file, :size => '20G'
        end

        if bridge_interface != ""
            if server_config[:macaddress2] != ""
              cfg.vm.network :public_network,
                :dev => bridge_interface,
                :mode => "bridge",
                :type => "direct",
                :mac => server_config[:macaddress2]
            else
              cfg.vm.network :public_network,
                :dev => bridge_interface,
                :mode => "bridge",
                :type => "direct"
            end
        end
      end

      if provider == 'virtualbox'
        # Virtualbox configuration
        cfg.vm.provider :virtualbox do |vm, override|

          if bridge_interface != ""
            vm.customize ["modifyvm", :id, "--nic2", "bridged"]
            vm.customize ["modifyvm", :id, "--bridgeadapter2", bridge_interface]
          end

          if server_config[:macaddress2] != ""
            vm.customize ["modifyvm", :id, "--macaddress2", server_config[:macaddress2]]
          end

          vm.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
          vm.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
          vm.customize ["modifyvm", :id, "--acpi", "off"]
          vm.customize ["modifyvm", :id, "--cpus", server_config[:cpus]]
          vm.customize ["modifyvm", :id, "--memory", server_config[:memory]]

        end
      end

      if server_config.k3os_config != ""

        # Download and install the envsubst binary if not present
        cfg.vm.provision "envsubst", type: "shell", inline: "if [ ! -f  \"/usr/local/bin/envsubst\" ]; then curl -L https://github.com/a8m/envsubst/releases/download/v1.1.0/envsubst-`uname -s`-`uname -m` -o envsubst; chmod +x envsubst; sudo mv envsubst /usr/local/bin; fi",  upload_path: "/home/rancher/provision-envsubst.sh"

        cfg.vm.provision "k3os-config-template", type: "file", source: server_config.k3os_config, destination: "/home/rancher/provision-k3os-config-template.yaml"

        # If the k3os_config is not empty then write out the environment variables
        k3os_config_env = "#!/bin/bash\n"
        if server_config.has_key?(:k3os_config_env)

          write_files = ""

          server_config.k3os_config_env.each do |arg, value|

            # If the argument is write_files then handle the value
            # so that this is accepted into yaml correctly

            if arg.to_s == 'write_files'

              # Retrieve the write_files config and convert to yaml
              server_config.k3os_config_env[:"#{arg.to_s}"].each do |details|

                if write_files == ""
                  write_files = '['
                end

                write_files += '{'

                details.each do |item, value|
                  write_files += '"' + item.to_s + '"' + ':' + " '" + value.to_s + "', "
                end

                write_files += '},'

              end

              if write_files != ""
                write_files = write_files + ']'
              end

              k3os_config_env = k3os_config_env + 'export write_files="' + write_files + '"' + "\n"

            else

              # Escape any double quotes
              value_escaped = value.to_s.gsub('"','\"')

              k3os_config_env = k3os_config_env + "export " + arg.to_s + '=' + '"' + value_escaped + '"' + "\n"

            end
          end
        end

        # Create the k3os-config.yaml file including any variables
        k3os_config_env = k3os_config_env + "\n" + "envsubst < provision-k3os-config-template.yaml > provision-k3os-config.yaml.tmp && mv provision-k3os-config.yaml.tmp provision-k3os-config.yaml"

        require "base64"
        # Upload the environment configuration
        cfg.vm.provision "k3os-config-env", type: "shell",  inline: "echo " + Base64.strict_encode64(k3os_config_env) + " | base64 -d > provision-k3os-config-env.sh; chmod 755 provision-k3os-config-env.sh; ./provision-k3os-config-env.sh", upload_path: "/home/rancher/provision-shell-k3os-config-env.sh"

        # If K3os configuration has updated, copy K3os config, remove the provision scripts and reboot
        # Otherwise remove the provision scripts

        # Set debug to true to debug the provisioning process

        provision_remove = "rm provision*.sh && rm provision*.yaml"
        if config.user.provision_debug == true
          provision_remove = "echo \"Debug Mode: Not deleting provision files\""
        end

        # Check if k3s should be kept or removed, if the /var/lib/k3s/k3s-keep is in place
        # then k3s is not removed, otherwise the directory is removed such as for setup.
        k3s_keep = "[ ! -f \"/var/lib/rancher/k3s-keep\" ] && rm -rf /var/lib/rancher/k3s; touch /var/lib/rancher/k3s-keep"

        cfg.vm.provision "copy-k3os-config", type: "shell", inline: "if ! cmp -s /home/rancher/provision-k3os-config.yaml /var/lib/rancher/k3os/config.yaml; then sudo cp /home/rancher/provision-k3os-config.yaml /var/lib/rancher/k3os/config.yaml && " + provision_remove + " && " + k3s_keep + " && " + "echo \"k3os configuration updated, rebooting\" && reboot; else " + provision_remove + "; fi", upload_path: "/home/rancher/provision-copy-k3os-config.sh"

      end
    end
  end
end

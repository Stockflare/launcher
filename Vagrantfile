# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu-12.04-x64-rvm-r3"

  # Use berkshelf!
  config.berkshelf.enabled = true

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "https://s3-eu-west-1.amazonaws.com/ik-public/ubuntu-12.04-x64-rvm-r3.box"

  # Perform an apt-get update before provisioning Chef dependencies
  config.vm.provision :shell, :inline => "apt-get update"

  # Run a vagrant bootstrap script
  config.vm.provision :shell, :path => "script/vagrant-bootstrap", :privileged => false

end
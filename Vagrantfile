Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-omnibus"
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

def json_attribs
  begin
    File.open("chef.json", "r") { |f| JSON.load(f) }
  rescue
    {}
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"

  # Use berkshelf!
  config.berkshelf.enabled = true

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Perform an apt-get update before provisioning Chef dependencies
  config.vm.provision :shell, :inline => "apt-get update"

  # Get latest version of chef
  config.omnibus.chef_version = :latest

  # Add vagrant user to sudoers
  config.vm.provision :shell, inline: "echo 'vagrant  ALL= (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers", :privileged => true

  config.vm.provision :chef_solo do |chef|

    # Add the recipes!
    chef.add_recipe "rvm::user"

    # You may also specify custom JSON attributes:
    chef.json = json_attribs

  end
  
  # Run a vagrant bootstrap script
  config.vm.provision :shell, inline: "/bin/bash --login /vagrant/script/vagrant/post-provision", :privileged => false

end
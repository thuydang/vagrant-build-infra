# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
# NOTE: vagrant-libvirt needs to run in series (not in parallel) to avoid
# # trying to create the network twice... eg: vagrant up --no-parallel
# # alternatively, you can just create the vm's one at a time manually...
#  
  config.vm.provision "shell", path: "puppet/scripts/bootstrap.sh"

  num_compute_nodes = (ENV['DEVSTACK_NUM_COMPUTE_NODES'] || 1).to_i

  # ip configuration
  control_ip = "192.168.50.20"
  compute_ip_base = "192.168.50."
  neutron_ex_ip = "192.168.111.11"
  compute_ips = num_compute_nodes.times.collect { |n| compute_ip_base + "#{n+21}" }
	
  # odl_dev node
  odl_dev_ip = "192.168.50.10"

  config.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.working_directory = "/vagrant/puppet"
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "base.pp"
  end
	# vagrant-kvm options
  config.vm.base_mac = "deadbeef2015"

  # vagrant-cachier
  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on the "Usage" link above
    config.cache.scope = :box

    # OPTIONAL: If you are using VirtualBox, you might want to use that to enable
    # NFS for shared folders. This is also very useful for vagrant-libvirt if you
    # want bi-directional sync

    config.cache.synced_folder_opts = {
      type: :nfs,
      # The nolock option can be useful for an NFSv3 client that wants to avoid the
      # NLM sideband protocol. Without this option, apt-get might hang if it tries
      # to lock files needed for /var/cache/* operations. All of this can be avoided
      # by using NFSv4 everywhere. Please note that the tcp option is not the default.
			# 
      # Now configure the host Firewall to accept incoming connections on port 13025, 2049 and port 111.  
			# iptables -I INPUT -j ACCEPT
      # iptables -I OUTPUT -j ACCEPT
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
	
	# NFS Sync
	config.vm.synced_folder "/mnt/nfv/vagrant/vagrant_common_nfs/ubuntu32_ima_build", "/vagrant_nfs", type: "nfs"

  # Devstack Controller
  config.vm.define "debian-7.8-i386-ima_build", primary: true do |control|
		control.vm.box = "debian-7.8-i386"
#		control.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
    control.vm.hostname = "debian-7.8-i386-dev"
    control.vm.network "private_network", ip: "#{control_ip}"
    ## control.vm.network "forwarded_port", guest: 8080, host: 8081
    ## control.vm.network "private_network", type: "dhcp", virtualbox__intnet: "intnet"
    ## neutron.vm.network "private_network", ip: "#{neutron_ex_ip}", virtualbox__intnet: "mylocalnet"
    control.vm.provider "vmware_fusion" do |v, override|
#			override.vm.box = 'trusty64'
#      override.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/vmware/opscode_ubuntu-14.04_chef-provisionerless.box"
    end
    control.vm.provider :virtualbox do |vb|
      vb.memory = 4096
    end
    control.vm.provider "vmware_fusion" do |vf|
      vf.vmx["memsize"] = "4096"
    end
		control.vm.provider :kvm do |kvm, override|
			kvm.memory_size = '4096m'
#override.vm.box = 'vagrant-kvm'
#override.vm.box_url = 'https://vagrant-kvm-boxes.s3.amazonaws.com/vagrant-kvm-trusty-20140330.box'
		end
		control.vm.provider :libvirt do |libvirt|
			libvirt.driver = 'kvm'	# needed for kvm performance benefits !
			libvirt.memory = 3024
			# leave out to connect directly with qemu:///system
			#libvirt.host = 'localhost'
			libvirt.connect_via_ssh = false
			libvirt.username = 'root'
			libvirt.storage_pool_name = 'default'
			#libvirt.default_network = 'default' # XXX: this does nothing
			#libvirt.default_prefix = 'gluster'	# prefix for your vm's!
		end
    control.vm.provision "puppet" do |puppet|
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.working_directory = "/vagrant/puppet"
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file  = "ubuntu32.pp"
    end
  end

end

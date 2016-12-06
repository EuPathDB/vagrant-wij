[
  { :name => 'vagrant-librarian-puppet', :version => '>= 0.9.2' },
].each do |plugin|
  if not Vagrant.has_plugin?(plugin[:name], plugin[:version])
    raise "#{plugin[:name]} #{plugin[:version]} is required. Please run `vagrant plugin install #{plugin[:name]}`"
  end
end

Vagrant.configure(2) do |config|

  config.vm.box_url = 'http://software.apidb.org/vagrant/webdev.json'
  config.vm.box = "ebrc/webdev"

  config.ssh.forward_agent = true
  config.ssh.pty = true

  config.vm.hostname = 'wij.vm'

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end

  config.vm.network :private_network, type: :dhcp
  config.vm.synced_folder ".", "/vagrant", type: "nfs"

  if ! File.exist?(File.dirname(__FILE__) + '/nolibrarian')
    config.librarian_puppet.puppetfile_dir = 'puppet'
    config.librarian_puppet.destructive = false
  end

  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    # Setting multiple TLD values requires my Landrush
    # fork at https://github.com/mheiges/landrush.git
    # (A pull request for the patch as been sent to the upstream landrush maintainer.)
    config.vm.provision :shell, inline: '/sbin/iptables-save -t nat > /root/landrush.iptables'
    config.landrush.tld = 'vm'
    #config.landrush.host 'wij.vm'
  end

  config.vm.provision :shell, path: 'bootstrap-puppet.sh'

  config.vm.synced_folder 'puppet/',
    '/etc/puppetlabs/code/',
    owner: 'root', group: 'root'

  config.vm.provision :puppet do |puppet|
    puppet.environment = 'savm'
    puppet.environment_path = 'puppet/environments'
    puppet.manifests_path = 'puppet/environments/savm/manifests'
    puppet.manifest_file = 'site.pp'
    puppet.hiera_config_path = 'puppet/hiera.yaml'
    #puppet.options = ['--debug --trace --verbose']
  end
  if ( Vagrant.has_plugin?('landrush') and config.landrush.enabled)
    config.vm.provision :shell, inline: '/sbin/iptables-restore < /root/landrush.iptables'
  end

end

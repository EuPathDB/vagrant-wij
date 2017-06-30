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

  irods_rest_port = 8180
  java_debug_port = 8800
  config.vm.network "forwarded_port", guest: irods_rest_port, host: irods_rest_port

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
    config.landrush.host_interface_excludes = [/lo[0-9]*/, /docker[0-9]+/, /tun[0-9]+/]
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

  config.vm.provision 'shell',
    inline: "firewall-cmd --permanent --add-rich-rule=\"rule port port=#{irods_rest_port} protocol='tcp' accept\""
    inline: "firewall-cmd --permanent --add-rich-rule=\"rule port port=#{java_debug_port} protocol='tcp' accept\""

  if ( Vagrant.has_plugin?('landrush') and config.landrush.enabled)
    config.vm.provision :shell, inline: '/sbin/iptables-restore < /root/landrush.iptables'
    # docker adds rules to the nat table that conflict with landrush dns.  The
    # above iptables-restore changes the order and breaks docker.  the most
    # straightforward way to address this is to restart the docker daemon so
    # they rules get re-added in the correct order.
    config.vm.provision :shell, inline: '/bin/systemctl restart  docker.service'
  end

end

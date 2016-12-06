# A quick hack to add ssh credentials to jenkins account to allow slave
# connection to joeuser account.
#
# This profile requires that the joeuser account already exists
# with home /usr/local/home/joeuser

class profiles::jenkins_joeuser_ssh {

  include ::ebrc_jenkins

  $key_prv = "${::ebrc_jenkins::user_home}/.ssh/id_rsa"
  $key_pub = "${::ebrc_jenkins::user_home}/.ssh/id_rsa.pub"
  $authorized_keys = '/usr/local/home/joeuser/.ssh/authorized_keys'

  file { "${::ebrc_jenkins::user_home}/.ssh":
    ensure => directory,
    owner  => $::ebrc_jenkins::user,
    mode   => '0700',
  } ->

  exec { 'generate jenkins node ssh key':
    path    => ['/bin', '/usr/bin',],
    user    => $::ebrc_jenkins::user,
    command => "ssh-keygen -t rsa -f ${key_prv}",
    unless  => ["test -f ${key_prv}", "test -f ${key_pub}"],
  } ->

  exec { 'installing jenkins node ssh public key':
    path    => ['/bin', '/usr/bin',],
    command => "cat ${key_pub} >> ${authorized_keys}",
    unless  => ["grep -qf ${key_pub} ${authorized_keys}"],
  }
  
}
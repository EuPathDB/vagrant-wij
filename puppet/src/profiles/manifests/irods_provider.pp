# Setup iRODS provider. 
# Includes iCAT postgresql database.

class profiles::irods_provider {

  include ::profiles::base
  include ::profiles::irods_consumer_base
  include ::profiles::irods_postgres_provider
  include ::irods::provider
  include ::profiles::irods_icommands
  #include ::profiles::irods_pam

  Class['profiles::base'] ->
  Class['profiles::irods_consumer_base'] ->
  Class['profiles::irods_postgres_provider'] ->
  Class['irods::provider'] ->
  file { '/etc/irods/ebrc.re':
    ensure => 'file',
    source => 'puppet:///modules/profiles/irods/ebrc.re',
    owner  => $::irods::globals::srv_acct,
    group  => $::irods::globals::srv_grp,
    mode   => '0600',
  } ->
  Class['profiles::irods_icommands']

  package { 'irods-resource-plugin-shareuf-4.2.0':
    ensure  => 'latest',
    require => Class['::irods::provider'],
  }

}

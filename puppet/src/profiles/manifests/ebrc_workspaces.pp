# this profile contains workspaces configurations that aren't directly
# jenkins or irods related. 

class profiles::ebrc_workspaces {

  $wrkspuser     = lookup({"name" => "workspaces::jenkins::wrkspuser"})
  $wrksppassword = lookup({"name" => "workspaces::jenkins::wrksppassword"})
  $wrksptoken    = lookup({"name" => "workspaces::jenkins::wrksptoken", "default_value" => $::wrkspuser_token}) # default to wrkspuser_token fact

  # these packages are needed for irods helper scripts
  package { 'python-irodsclient':
    ensure   => installed,
    provider => 'pip',
  }
  package { 'python-jenkins':
    ensure => installed,
  }

  # generate template used by irods job runner (executeJobFile.py)
  file { '/var/lib/irods/jenkins.conf':
    ensure  => 'file',
    content => template('profiles/jenkins.conf.erb'),
    require => Class['irods::provider'],
  }
  

}


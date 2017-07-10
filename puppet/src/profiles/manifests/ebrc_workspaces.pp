class profiles::ebrc_workspaces {

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


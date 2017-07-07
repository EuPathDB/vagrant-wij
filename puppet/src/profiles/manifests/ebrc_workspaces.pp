class profiles::ebrc_workspaces {

  package { 'python-irodsclient':
    ensure   => installed,
    provider => 'pip',
  }
  package { 'python-jenkins':
    ensure => installed,
  }
  

}


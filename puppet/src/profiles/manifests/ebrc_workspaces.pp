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
  

  # svn file links
  $checkout_location = lookup({"name" => 'workspaces::svn_files::checkout_location'})
  $checkout_revision = lookup({"name" => "workspaces::svn_files::checkout_revision", "default_value" => "HEAD"})

  vcsrepo { $checkout_location:
    ensure        => present,
    provider      => svn,
    source        => 'https://cbilsvn.pmacs.upenn.edu/svn/apidb/EuPathDBIrods/trunk',
    revision      => $checkout_revision,
  }

  # create links to individual files in svn checkout
  $msi_bin = '/var/lib/irods/msiExecCmd_bin'
  $link_defaults = { ensure => 'link', require => Class[irods::provider] }
  $links = {
    "$msi_bin/eventGenerator.py"                         => { target => "$checkout_location/Scripts/remoteExec/eventGenerator.py" },
    "$msi_bin/executeJobFile.py"                         => { target => "$checkout_location/Scripts/remoteExec/executeJobFile.py" },
    "/etc/irods/ud.re"                                   => { target => "$checkout_location/Scripts/ud.re" },
  }

  create_resources(file, $links, $link_defaults)

}


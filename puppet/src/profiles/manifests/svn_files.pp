class profiles::svn_files {

  $checkout_location = lookup('profiles::svn_files::checkout_location')
  $checkout_revision = lookup({"name" => "profiles::svn_files::checkout_revision", "default_value" => "HEAD"})

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
    #TODO this should probably be elsewhere, 
    "/usr/local/home/jenkins/irodsWorkspacesJobs.groovy" => { target => "$checkout_location/Resources/JenkinsJobs/irodsWorkspacesJobs.groovy" },
  }

  create_resources(file, $links, $link_defaults)


}


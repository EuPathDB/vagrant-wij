# This class manages workspaces(WS) specific jenkins configurations

class profiles::ebrc_workspaces_jenkins {

  $dslconfig     = "/usr/local/home/jenkins/Instances/WS/dslconfig.groovy"
  $adminuser     = lookup({"name" => "workspaces::jenkins::adminuser"})
  $adminpassword = lookup({"name" => "workspaces::jenkins::adminpassword"})
  $wrkspuser     = lookup({"name" => "workspaces::jenkins::wrkspuser"})
  $wrksppassword = lookup({"name" => "workspaces::jenkins::wrksppassword"})
  $nodes         = lookup({"name" => "workspaces::jenkins::nodes"})
  $site_environment = "savm"
  $confset       = "wij_configuration_set"

  $plugins = [
    'antisamy-markup-formatter',
    'ant',
    'build-blocker-plugin',
    'build-timeout',
    'credentials',
    'email-ext',
    'external-monitor-job',
    'git',
    'git-client',
    'github',
    'gradle',
    'groovy',
    'job-dsl',
    'junit',
    'mailer',
    'matrix-auth',
    'matrix-project',
    'maven-plugin',
    'parameterized-trigger',
    'pipeline-stage-step',
    'pipeline-milestone-step',
    'pipeline-build-step',
    'pipeline-input-step',
    'pipeline-graph-analysis',
    'pipeline-rest-api',
    'pipeline-stage-view',
    'plain-credentials',
    'preSCMbuildstep',
    'resource-disposer',
    'role-strategy',
    'run-condition',
    'scm-api',
    'script-security',
    'ssh-credentials',
    'ssh-slaves',
    'structs',
    'subversion',
    'token-macro',
    'workflow-aggregator',
    'workflow-support',
    'ws-cleanup',
  ]

  Class['::profiles::ebrc_jenkins'] ->
  Class['::profiles::ebrc_workspaces_jenkins']

  # this handles user and plugin setup
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d/10_init.groovy':
    ensure  => 'file',
    content => template('profiles/init.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  # this creates /usr/local/home/jenkins/jenkins_token.txt, which is linked
  # to /etc/facter/facts.d/ to provide this token as a fact to be used
  # elsewhere
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d/12_token.groovy':
    ensure  => 'file',
    content => template('profiles/token.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  # this sets up role based authentication
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d/15_auth.groovy':
    ensure  => 'file',
    content => template('profiles/auth.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  # this creates the irods node
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d/20_irods_node.groovy':
    ensure  => 'file',
    content => template('profiles/irods_node.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  # this executes the irodsWorkspacesJobs.groovy script that lives in svn,
  # but is linked to /usr/local/home/jenkins/
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d/60_seed_job.groovy':
    ensure  => 'file',
    content => template('profiles/seed_job.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  file { '/usr/local/home/jenkins/irodsWorkspacesJobs.groovy':
    ensure  => 'file',
    content => template('profiles/irodsWorkspacesJobs.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }

  # template for all groovy script confs
  file { '/usr/local/home/jenkins/Instances/WS/dslconfig.groovy':
    ensure  => 'file',
    content => template('profiles/dslconfig.groovy.erb'),
    notify  => Service['jenkins@WS'],
  }


  # because this vm instance will dynamically generate the api token, the
  # 12_api_token.groovy script creates a file in jenkin's home with the
  # credentials.  we link it into facts.d here so that it can be used in puppet
  # elsewhere.  In a production scenario, we would likely set the token in
  # hiera directly.

  file { ['/etc/facter', '/etc/facter/facts.d']:
    ensure => directory,
  }

  file { '/etc/facter/facts.d/jenkins_token.txt':
    ensure => link,
    target => '/usr/local/home/jenkins/jenkins_token.txt',
    mode   => '700',
  }

}

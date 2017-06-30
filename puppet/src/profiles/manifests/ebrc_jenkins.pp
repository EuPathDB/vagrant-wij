# manage requirements for Jenkins server instances
# for EuPathDB
class profiles::ebrc_jenkins {

  include ::profiles::base
  include ::profiles::ebrc_java_stack
  include ::profiles::local_home
  include ::profiles::jenkins_joeuser_ssh
  include ::ebrc_jenkins

  $adminuser = 'admin'
  $adminpassword = 'santafe7'
  $wrkspuser = 'wrkspuser'
  $wrksppassword = 'password'

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

  Class['::profiles::ebrc_java_stack'] ->
  Class['::profiles::local_home'] ->
  Class['::ebrc_jenkins'] ->
  Class['::profiles::jenkins_joeuser_ssh']

  # groovy init scripts.  These are  executed by jenkins at startup, in
  # lexical order
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy.d':
    ensure => 'directory'
  }

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

  # generate template used by irods job runner (executeJobFile.py)
  file { '/var/lib/irods/jenkins.conf':
    ensure  => 'file',
    content => template('profiles/jenkins.conf.erb'),
    require => Class['irods::provider'],
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


  $jenkins_instances = hiera('ebrc_jenkins::instances')
  $jenkins_instances.each |$instance, $conf| {
    $port = $conf['http_port']
    firewalld_rich_rule { "Jenkins instance ${instance}":
      ensure => present,
      zone   => 'public',
      port   => {
        'port'     => $port,
        'protocol' => 'tcp',
      },
      action => 'accept',
    }

  }

}

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

  # TO BE REFACTORED
  file { '/usr/local/home/jenkins/Instances/WS/init.groovy':
    ensure  => 'file',
    content => template('profiles/init.groovy.erb'),
    notify  => Service['jenkins@WS'],
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
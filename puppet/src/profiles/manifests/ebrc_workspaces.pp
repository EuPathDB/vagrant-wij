class profiles::ebrc_workspaces {
  include ::workspaces
  include ::workspaces::jenkins

  Class['::profiles::ebrc_jenkins'] ->
  Class['::profiles::ebrc_workspaces']

}


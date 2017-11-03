# setup EuPathDB YUM repo.
#
class profiles::eupathrepo {
  include ::profiles::ebrc_ca_bundle
  include ::ebrc_yum_repo
  Class['profiles::ebrc_ca_bundle'] ->
  Class['ebrc_yum_repo']
}
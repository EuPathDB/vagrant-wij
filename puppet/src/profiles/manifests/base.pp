

class profiles::base {

  package { [
      'ack',
      'bind-utils',
      'gcc-c++',
      'git',
      'jq',
      'mlocate',
      'moreutils',
      'nmap',
      'ntp',
      'rsync',
      'strace',
    ]:
    ensure => 'installed',
  }

}
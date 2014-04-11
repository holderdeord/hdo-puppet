class hdo::common {
  include hdo::params

  $home = "/home/${hdo::params::user}"

  package { [
      'htop',
      'vim',
      'build-essential',
      'git-core',
      'emacs23-nox',
      'sysstat',
      'curl',
      'unzip',
      'iptables-persistent',
    ]:
    ensure => installed,
  }

  include ruby
  ruby::gem { 'bundler': }

  file { "${home}/.emacs":
    ensure  => file,
    content => '(setq make-backup-files nil)'
  }

  user { $hdo::params::user:
    ensure     => present,
    home       => $home,
    managehome => true,
    shell      => '/bin/bash',
    groups     => $hdo::params::group
  }

  file { $hdo::params::webapp_root:
    ensure  => 'directory',
    mode    => '0775',
    owner   => $hdo::params::user
  }

  file { "/home/${hdo::params::user}":
    ensure  => directory,
    owner   => $hdo::params::user,
    require => User[$hdo::params::user],
  }

  Ssh_authorized_key <| user == $hdo::params::user |>

  file { "${home}/.gemrc":
    ensure  => file,
    owner   => $hdo::params::user,
    mode    => '0644',
    content => 'gem: --no-rdoc --no-ri\n'
  }
}

#
# Installs Ruby 1.9.1
#

class ruby {
  package {
    "ruby1.9.1":
      ensure => "installed";
    "ruby1.9.1-dev":
      ensure => "installed";
  }

  # Make the system-wide ruby link by default point at 1.9.1
  file { "/usr/bin/ruby":
    ensure  => "link",
    target  => "/etc/alternatives/ruby",
    require => Package['ruby1.9.1']
  }
}

define ruby::gem {
  exec { "${name}-gem":
    command   => "gem1.9.1 install $name",
    onlyif    => "gem1.9.1 search -i $name | grep false",
    require   => Package["ruby1.9.1"],
    logoutput => on_failure
  }
}

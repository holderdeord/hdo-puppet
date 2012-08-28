import 'gem.pp'

#
# Installs Ruby 1.9.1
#

class ruby {
  package {
    'ruby1.9.1':
      ensure => 'installed';
    'ruby1.9.1-dev':
      ensure => 'installed';
  }

  # Make sure the default Ruby is 1.9
  exec { 'update-alternatives-ruby-19':
    command   => 'update-alternatives --set ruby /usr/bin/ruby1.9.1',
    unless    => 'ruby -v | grep "ruby 1.9"',
    require   => Package['ruby1.9.1'],
    logoutput => on_failure
  }
}

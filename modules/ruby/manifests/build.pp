class ruby::build {
  $download = '/tmp/ruby-build'

  exec { 'install-ruby-build':
    command => "git clone git://github.com/sstephenson/ruby-build ${download} && cd ${download} && ./install.sh",
    creates => '/usr/local/bin/ruby-build',
    require => Package['git-core'],
  }
}
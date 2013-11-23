class ruby::build {
  $dir = '/opt/ruby-build'

  exec { 'clone-ruby-build':
    command => "git clone git://github.com/sstephenson/ruby-build ${dir} && cd ${dir}",
    creates => $dir,
    require => Package['git-core'],
  }

  exec { 'update-ruby-build':
    command => 'git reset --hard origin/master && git pull && ./install.sh',
    cwd     => $dir,
    require => Exec['clone-ruby-build']
  }
}
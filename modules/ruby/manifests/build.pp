class ruby::build {
  $dir = '/opt/ruby-build'

  exec { 'clone-ruby-build':
    command => "git clone git://github.com/sstephenson/ruby-build ${dir} && cd ${dir}",
    creates => $dir,
    require => Package['git-core'],
  }

  # this sha is known to work with rbenv from apt
  exec { 'update-ruby-build':
    command => 'git reset --hard origin/master && git pull && git reset --hard 458d3331675f9f35517cfb095489496eff785aa3 && ./install.sh',
    cwd     => $dir,
    require => Exec['clone-ruby-build']
  }
}
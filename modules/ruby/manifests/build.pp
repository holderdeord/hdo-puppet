class ruby::build {
  $dir      = '/opt/ruby-build'
  $revision = 'e932d47195d76d6be9635a012056069e794039e0'

  exec { 'clone-ruby-build':
    command => "git clone git://github.com/sstephenson/ruby-build ${dir} && cd ${dir}",
    creates => $dir,
    require => Package['git-core'],
  }

  exec { 'update-ruby-build':
    command => "git reset --hard origin/master && git pull && git reset --hard ${revision} && ./install.sh",
    cwd     => $dir,
    onlyif  => "git rev-parse HEAD | grep -v ${revision} || [ ! -f /usr/local/bin/ruby-build ]",
    require => Exec['clone-ruby-build'],
  }
}
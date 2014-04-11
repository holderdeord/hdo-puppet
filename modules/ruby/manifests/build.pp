class ruby::build {
  $dir      = '/opt/ruby-build'
  $revision = '0a9b5e3a1e2c38c58abe8ca10d60f8d0c8a14249'

  exec { 'clone-ruby-build':
    command => "git clone git://github.com/sstephenson/ruby-build ${dir} && cd ${dir}",
    creates => $dir,
    require => Package['git-core'],
  }

  exec { 'update-ruby-build':
    command => "git reset --hard origin/master && git pull && git reset --hard ${revision} && ./install.sh",
    cwd     => $dir,
    onlyif  => "git rev-parse HEAD | grep -v ${revision}",
    require => Exec['clone-ruby-build'],
  }
}
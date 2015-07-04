class ruby::rbenv {
  $dir      = '/opt/rbenv'
  $revision = '83ac0fbd94186f8f75a8217229ca845b0d25c131'

  exec { 'clone-rbenv':
    command => "git clone git://github.com/sstephenson/rbenv.git ${dir} && cd ${dir}",
    creates => $dir,
    require => Package['git-core'],
  }

  exec { 'update-rbenv':
    command => "git reset --hard origin/master && git pull && git reset --hard ${revision}",
    onlyif  => "git rev-parse HEAD | grep -v ${revision}",
    cwd     => $dir,
    require => Exec['clone-rbenv'],
  }

  file { '/etc/profile.d/rbenv.sh':
    ensure  => present,
    mode    => '0755',
    content => template('ruby/rbenv.sh.erb'),
  }
}
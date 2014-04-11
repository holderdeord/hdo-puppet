class ruby::rbenv {
  $dir      = '/opt/rbenv'
  $revision = '9375e99f921f428849f19efe2a2e500b3295d1a7'

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
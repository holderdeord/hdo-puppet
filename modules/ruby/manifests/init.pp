class ruby {
  package { 'rbenv': ensure => installed }
  include ruby::build

  $rbenv_root = '/usr/lib/rbenv'
  $version    = '2.0.0-p247'
  $binary     = "${rbenv_root}/shims/ruby"
  $gems       = "${rbenv_root}/versions/${version}/lib/ruby/gems/2.0.0/gems"

  file { "${ruby::rbenv_root}/global":
    ensure  => file,
    mode    => '0755',
    content => $version,
    require => Ruby::Version[$version],
  }

  file { '/etc/profile.d/rbenv.sh':
    ensure  => present,
    mode    => '0755',
    content => template('ruby/rbenv.sh.erb'),
    require => File["${ruby::rbenv_root}/global"]
  }

  ruby::version { $version: }
}

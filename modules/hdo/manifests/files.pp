class hdo::files(
  $root = '/webapps/files',
  $server_name = 'files.holderdeord.no'
  ) {
  include hdo::common
  include hdo::params

  $files_root = $root
  $ssl        = true

  file { [$files_root, '/webapps/valgvake']:
    ensure => 'directory',
    mode   => '0775',
    owner  => 'hdo'
  }

  file { "${passenger::nginx::sites_dir}/holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-www-redirect-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { "${passenger::nginx::sites_dir}/files.holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-files-vhost.conf.erb'),
    notify  => Service['nginx']

  }

  exec { 'clone-hal-browser':
    command => "git clone git://github.com/mikekelly/hal-browser ${files_root}/hal-browser",
    user    => hdo,
    creates => "${files_root}/hal-browser",
    require => File[$files_root]
  }

}

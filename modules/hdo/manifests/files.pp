class hdo::files {
  include hdo::common
  include hdo::params

  $files_root  = '/webapps/files'

  file { $files_root:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  class { 'passenger::nginx': port => 80 }

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

}
class hdo::webapp::nginx inherits hdo::webapp {
  include passenger::nginx

  $www_root                = $hdo::params::public_dir
  $passenger_min_instances = $passenger::params::min_instances

  file { "${passenger::nginx::sites_dir}/10-beta.holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-beta-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { "${passenger::nginx::sites_dir}/20-holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-www-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { "${passenger::nginx::sites_dir}/30-files.holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-files-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  file { "${passenger::nginx::sites_dir}/99-server_status.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx_server_status.vhost.conf.erb'),
    notify  => Service['nginx']
  }
}

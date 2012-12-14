class hdo::webapp::beta inherits hdo::webapp {
  $listen      = '80'
  $server_name = 'beta.holderdeord.no'

  if $hdo::params::environment != 'production' {
    warning("including hdo::webapp::beta, but hdo::params::environment == ${hdo::params::environment}")
  }

  file { "${passenger::nginx::sites_dir}/10-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-app-vhost.conf.erb'),
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
}

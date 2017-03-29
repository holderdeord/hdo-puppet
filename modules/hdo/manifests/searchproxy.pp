class hdo::searchproxy(
  $server_name = $::fqdn,
  $ssl         = true,
  $cors        = true
) {
  include hdo::common
  include hdo::params

  file { "${passenger::nginx::sites_dir}/search-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-es-proxy-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}

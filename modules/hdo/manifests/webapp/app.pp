class hdo::webapp::app inherits hdo::webapp {
  if $hdo::params::environment != 'production' {
    warning("including hdo::webapp::app, but hdo::params::environment == ${hdo::params::environment}")
  }

  $listen      = '80'
  $server_name = $::fqdn

  class { 'passenger::nginx': port => $listen }

  file { "${passenger::nginx::sites_dir}/10-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }
}

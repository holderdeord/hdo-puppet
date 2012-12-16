class hdo::webapp::staging inherits hdo::webapp {
  if $hdo::params::environment != 'staging' {
    warning("including hdo::webapp::staging, but hdo::params::environment == ${hdo::params::environment}")
  }

  $listen      = '127.0.0.1:8080' # varnish in front
  $server_name = 'staging.holderdeord.no'

  class { 'passenger::nginx': listen => $listen }

  file { "${passenger::nginx::sites_dir}/10-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }
}
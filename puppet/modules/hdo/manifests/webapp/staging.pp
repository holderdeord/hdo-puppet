class hdo::webapp::staging inherits hdo::webapp {
  $listen      = '8080' # vagrant in front
  $server_name = 'staging.holderdeord.no'

  if $hdo::params::environment != 'staging' {
    warning("including hdo::webapp::staging, but hdo::params::environment == ${hdo::params::environment}")
  }

  file { "${passenger::nginx::sites_dir}/10-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }
}
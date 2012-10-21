class hdo::webapp::nginx inherits hdo::webapp {
  include passenger::nginx

  $www_root                = $hdo::params::public_dir
  $passenger_min_instances = $passenger::params::min_instances

  file { "${passenger::nginx::sites_dir}/holderdeord.no.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-vhost.conf.erb'),
    notify  => Service['nginx']
  }
}
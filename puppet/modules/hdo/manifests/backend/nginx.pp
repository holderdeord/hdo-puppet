class hdo::backend::nginx inherits hdo::backend {
  include passenger::nginx

  $server_name             = "beta.holderdeord.no"
  $www_root                = $hdo::params::public_dir
  $passenger_min_instances = $passenger::params::min_instances

  file { "${passenger::nginx::sites_dir}/${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-vhost.conf.erb'),
    notify  => Service['nginx']
  }
}
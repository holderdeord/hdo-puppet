class hdo::rebels(
  $server_name = $::fqdn,
  $ssl         = true,
  $restrict    = false,
) {
  include hdo::common
  include hdo::params

  $repo_root = "${hdo::params::webapp_root}/hdo-rebels"
  $site_root = "${repo_root}/build"

  exec { 'clone hdo-rebels':
    command => "git clone git://github.com/holderdeord/hdo-rebels ${repo_root}",
    user    => hdo,
    creates => $repo_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'npm install hdo-rebels':
    command => "bash -l -c 'npm install'",
    cwd     => $repo_root,
    user    => hdo,
    require => Exec['clone hdo-rebels']
  }

  exec { 'build hdo-rebels':
    command => "bash -l -c 'npm run build'",
    creates => $site_root,
    user    => hdo,
    cwd     => $repo_root,
    require => Exec['npm install hdo-rebels']
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': }
  }

  file { "${passenger::nginx::sites_dir}/rebels-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-static-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}

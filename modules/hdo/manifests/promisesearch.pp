class hdo::promisesearch(
  $server_name  = $::fqdn,
  $server_alias = false,
  $ssl          = true,
  $restrict     = false,
) {
  include hdo::common
  include hdo::params

  $repo_root = "${hdo::params::webapp_root}/hdo-promise-search"
  $site_root = "${repo_root}/build"

  exec { 'clone hdo-promise-search':
    command => "git clone git://github.com/holderdeord/hdo-promise-search ${repo_root}",
    user    => hdo,
    creates => $repo_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'npm install hdo-promise-search':
    command => "bash -l -c 'npm install'",
    cwd     => $repo_root,
    user    => hdo,
    require => Exec['clone hdo-promise-search']
  }

  exec { 'build hdo-promise-search':
    command => "bash -l -c 'npm run build'",
    creates => $site_root,
    user    => hdo,
    cwd     => $repo_root,
    require => Exec['npm install hdo-promise-search']
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': }
  }

  file { "${passenger::nginx::sites_dir}/promisesearch-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-static-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}

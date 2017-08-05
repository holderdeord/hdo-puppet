class hdo::promisetracker(
  $server_name  = $::fqdn,
  $server_alias = false,
  $ssl          = true,
  $restrict     = false,
) {
  include hdo::common
  include hdo::params

  $repo_root = "${hdo::params::webapp_root}/hdo-promise-tracker"
  $indexer_root = "${repo_root}/indexer"
  $webapp_root = "${repo_root}/webapp"
  $site_root = "${webapp_root}/build"

  exec { 'clone hdo-promise-tracker':
    command => "git clone git://github.com/holderdeord/hdo-promise-tracker ${repo_root}",
    user    => hdo,
    creates => $repo_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'npm install hdo-promise-tracker indexer':
    command => "bash -l -c 'npm install'",
    cwd     => $indexer_root,
    user    => hdo,
    require => Exec['clone hdo-promise-tracker']
  }

  exec { 'npm install hdo-promise-tracker webapp':
    command => "bash -l -c 'npm install'",
    cwd     => $webapp_root,
    user    => hdo,
    require => Exec['clone hdo-promise-tracker']
  }

  exec { 'build hdo-promise-tracker webapp':
    command => "bash -l -c 'npm run build'",
    creates => $site_root,
    user    => hdo,
    cwd     => $webapp_root,
    require => Exec['npm install hdo-promise-tracker webapp']
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': }
  }

  file { "${passenger::nginx::sites_dir}/promisetracker-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-static-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}

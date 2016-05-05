class hdo::cards(
  $server_name = $::fqdn,
  $ssl         = true,
  $restrict    = false,
) {
  include hdo::common
  include hdo::params

  $repo_root = "${hdo::params::webapp_root}/hdo-cards"
  $site_root = "${repo_root}/build"

  exec { 'clone hdo-cards':
    command => "git clone git://github.com/holderdeord/hdo-cards ${repo_root}",
    user    => hdo,
    creates => $repo_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { 'npm install hdo-cards':
    command => "bash -l -c 'npm install'",
    cwd     => $repo_root,
    user    => hdo,
    require => Exec['clone hdo-cards']
  }

  exec { 'build hdo-cards':
    command => "bash -l -c 'npm run build'",
    creates => $site_root,
    user    => hdo,
    cwd     => $repo_root,
    require => Exec['npm install hdo-cards']
  }

  cron { 'hdo-cards-update':
    ensure      => 'present',
    command     => "bash -l -c 'cd ${hdo::params::repo_root} && ./node_modules/.bin/babel-node script/update.js --input /webapps/files/gdrive --output ./build/data'",
    user        => hdo,
    environment => ["RAILS_ENV=${hdo::params::environment}", 'PATH=/usr/local/bin:/usr/bin:/bin', "MAILTO=${hdo::params::admin_email}"],
    require     => Exec['build hdo-cards'],
    hour        => '*',
    minute      => '*'
  }

  if ! defined(Class['passenger::nginx']) {
    class { 'passenger::nginx': }
  }

  file { "${passenger::nginx::sites_dir}/cards-${server_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-static-vhost.conf.erb'),
    notify  => Service['nginx']
  }

}

class hdo::portal(
  $ensure      = 'present',
  $server_name = 'portal.holderdeord.no',
  $port        = 7575,
  $ssl         = false
  ) {

  if vhost != false {
    fail('not yet implemented: hdo-portal vhost')
  }

  include hdo::common
  include hdo::params

  $app_name         = 'hdo-portal'
  $app_root         = "${hdo::params::webapp_root}/${app_name}"
  $public_root      = "${webapp_root}/build"
  $app_log          = "/var/log/${app_name}.log"

  exec { "clone ${app_name}":
    command => "git clone git://github.com/holderdeord/${app_name} ${app_root}",
    user    => hdo,
    creates => $app_root,
    require => [Package['git-core'], File[$hdo::params::webapp_root]]
  }

  exec { "build ${app_name} webapp":
    command     => "bash -l -c 'npm run build'",
    user        => hdo,
    cwd         => $app_root,
    onlyif      => "ls ${public_root}/ | grep -Ev 'bundle.+.js$' > /dev/null",
    environment => ["HOME=${hdo::params::home}"],
    require     => [Class['hdo::nodejs'], Exec["clone ${app_name}"]]
  }

  file { $app_log:
    ensure => $ensure,
    owner  => hdo
  }

  $purge = true

  file { "${passenger::nginx::sites_dir}/portal.holderdeord.no.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('hdo/nginx-node-app-vhost.conf.erb'),
    notify  => Service['nginx']
  }

  $description = $app_name
  $author      = 'hdo-puppet'
  $user        = 'hdo'

  file { "/etc/init/${app_name}.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    content => template('hdo/node-upstart.conf.erb'),
    require => File[$app_log]
  }

  logrotate::rule { $app_name:
    ensure       => $ensure,
    path         => $app_log,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  logrotate::rule { "${app_name}-indexer":
    ensure       => $ensure,
    path         => $indexer_log,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  if $ensure == 'present' {
    service { $app_name: ensure => 'running' }
  } else {
    service { $app_name: ensure => 'stopped' }
  }

  file { '/etc/sudoers.d/allow-hdo-service-hdo-portal':
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0440',
    content => "hdo ALL = (root) NOPASSWD: /sbin/start ${app_name}, /sbin/stop ${app_name}, /sbin/restart ${app_name}, /sbin/status ${app_name}\n",
  }

  file { '/etc/profile.d/hdo-portal.sh':
    ensure  => $ensure,
    mode    => '0775',
    content => template('hdo/hdo-portal-profile.sh')
  }

}

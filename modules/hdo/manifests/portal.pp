class hdo::portal(
    $ensure      = 'present',
    $server_name = 'portal.holderdeord.no',
    $port        = 7373,
    $ssl         = false,
    $passenger   = false,
  ) {

  include hdo::common
  include hdo::params

  $app_name         = 'hdo-portal'
  $app_root         = "${hdo::params::webapp_root}/${app_name}"
  $public_root      = "${app_root}/build"
  $app_log          = "/var/log/${app_name}.log"

  exec { "clone ${app_name}":
    command => "git clone git://github.com/holderdeord/${app_name} ${app_root} && cd ${app_root} && npm install",
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

  if ($ensure == 'present' and $passenger != true) {
    service { $app_name: ensure => 'running' }
  } else {
    service { $app_name: ensure => 'stopped' }
  }

  if ($passenger == true) {
    file { '/etc/sudoers.d/allow-hdo-service-hdo-portal':
      ensure  => 'absent',
    }
  } else {
    file { '/etc/sudoers.d/allow-hdo-service-hdo-portal':
      ensure  => $ensure,
      owner   => root,
      group   => root,
      mode    => '0440',
      content => template('hdo/node-app-sudoers.erb'),
    }
  }


  file { '/etc/profile.d/hdo-portal.sh':
    ensure  => $ensure,
    mode    => '0775',
    content => template('hdo/hdo-portal-profile.sh')
  }

}

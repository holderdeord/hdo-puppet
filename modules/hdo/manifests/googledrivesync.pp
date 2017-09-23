class hdo::googledrivesync(
  $ensure = present,
  $interval = '15s'
) {
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail('hdo::googledrivesync ensure parameter must be absent or present')
  }

  $app_name    = 'hdo-google-drive-sync'
  $author      = 'hdo-puppet'
  $user        = 'hdo'

  $output_dir        = '/webapps/files/gdrive'
  $log_path          = '/var/log/google-drive-sync.log'
  $state_dir         = '/var/lib/hdo-google-drive-sync'
  $state_path        = "${state_dir}/state.json"
  $credentials_path  = "${state_dir}/credentials.json"
  $plugin_path       = "${state_dir}/plugin.js"
  $systemd_conf_path = "/lib/systemd/system/${app_name}.service"

  file { $log_path:
    ensure => file,
    owner  => hdo
  }

  logrotate::rule { 'hdo-googledrivesync':
    ensure       => $ensure,
    path         => $log_path,
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  file { $state_dir:
    ensure => directory,
    owner  => hdo
  }

  file { $output_dir:
    ensure  => directory,
    owner   => hdo,
    require => Class['hdo::files']
  }

  file { $plugin_path:
    ensure  => file,
    owner   => hdo,
    source  => 'puppet:///modules/hdo/googledrivesync/plugin.js',
    require => File[$state_dir],
    notify  => Service[$app_name]
  }

  file { $credentials_path:
    ensure  => file,
    owner   => hdo,
    content => hiera('google_drive_api_credentials', '{}'),
    require => File[$state_dir],
    notify  => Service[$app_name]
  }

  package { 'google-drive-sync':
    ensure   => '1.1.3',
    provider => 'npm',
  }

  file { $systemd_conf_path:
    ensure  => $ensure,
    owner   => root,
    group   => root,
    content => template('hdo/systemd-google-drive-sync.conf.erb'),
    require => [File[$log_path], File[$credentials_path], Package['google-drive-sync']]
  }

  service { $app_name:
    ensure   => running,
    require  => File[$systemd_conf_path],
    provider => systemd
  }

}
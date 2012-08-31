class hdo::unicorn {
  include ruby
  include hdo::params

  $app_root         = $hdo::params::app_root
  $config           = $hdo::params::unicorn_conf
  $unix_socket      = $hdo::params::unicorn_socket
  $pid_path         = $hdo::params::unicorn_pid
  $log_path         = $hdo::params::unicorn_log
  $worker_processes = $hdo::params::unicorn_worker_processes
  $user             = $hdo::params::user
  $group            = $hdo::params::group

  ruby::gem { 'unicorn':
    name    => 'unicorn',
    version => '~> 4.3.1'
  }

  file { [$hdo::params::unicorn_run_dir, $hdo::params::unicorn_log_dir]:
    ensure => directory,
    owner  => 'hdo'
  }

  file { '/etc/init.d/unicorn-hdo':
    ensure  => file,
    mode    => '0755',
    content => template('hdo/unicorn_init.sh.erb')
  }

  file { $config:
    ensure  => file,
    content => template('hdo/unicorn.conf.erb')
  }
}
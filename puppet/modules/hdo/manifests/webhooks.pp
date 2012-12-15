class hdo::webhooks {
  include hdo::common
  include passenger::apache

  $appdir = '/opt/hdo-site'
  $root   = '/webapps/hdo-webhook-deployer'
  $logdir = "${root}/log"
  $tmpdir = "${root}/tmp"
  $token  = hiera('hdo_travis_token', 'default-invalid-token')

  file { [$appdir, $logdir, $tmpdir]:
    ensure => directory,
    owner  => hdo,
  }

  exec { 'git-clone-hdo-webhook-deployer':
    command   => "git clone https://github.com/holderdeord/hdo-webhook-deployer.git ${root}",
    user      => hdo,
    creates   => $root,
    logoutput => on_failure,
    notify    => Exec['bundle-install-hdo-webhook-deployer'],
    require   => Class['passenger']
  }

  exec { 'bundle-install-hdo-webhook-deployer':
    command     => 'bundle install --deployment --without test development',
    user        => hdo,
    cwd         => $root,
    logoutput   => on_failure,
    refreshonly => true,
    require     => Class['passenger'],
  }

  exec { 'restart-hdo-webhook-deployer':
    command     => "touch ${tmpdir}/restart.txt",
    user        => hdo,
    refreshonly => true,
  }

  exec { 'git-clone-hdo-site':
    command   => "git clone https://github.com/holderdeord/hdo-site.git ${appdir}",
    user      => hdo,
    creates   => "${appdir}/Gemfile",
    logoutput => on_failure,
    require   => File[$appdir],
  }

  file { "${root}/config/production.json":
    ensure  => file,
    owner   => hdo,
    mode    => '0644',
    content => template('hdo/webhooks.json'),
    require => Exec['git-clone-hdo-webhook-deployer'],
    notify  => Exec['restart-hdo-webhook-deployer'],
  }

  logrotate::rule { 'hdo-webhook-deployer':
    path         => "${logdir}/*",
    compress     => true,
    copytruncate => true,
    dateext      => true,
    ifempty      => false,
    missingok    => true
  }

  apache::vhost { 'hooks.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '80',
    servername    => 'hooks.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'hdo/apache-webhooks-vhost.conf.erb',
    docroot       => "${root}/public",
    docroot_owner => hdo,
    docroot_group => hdo,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [Exec['git-clone-hdo-webhook-deployer'], User['hdo']],
  }

}
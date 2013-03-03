class hdo::webhooks {
  include hdo::common
  include passenger::apache

  $appdir = '/opt/hdo-site'
  $root   = '/webapps/hdo-webhook-deployer/current'
  $logdir = "${root}/log"
  $tmpdir = "${root}/tmp"
  $token  = hiera('hdo_travis_token', 'default-invalid-token')

  file { $appdir:
    ensure => directory,
    owner  => hdo,
  }

  file { [$logdir, $tmpdir]:
    ensure  => directory,
    owner   => hdo
  }

  exec { 'restart-hdo-webhook-deployer':
    command     => "touch ${tmpdir}/restart.txt",
    user        => hdo,
    refreshonly => true,
  }

  file { "${root}/config/production.json":
    ensure  => file,
    owner   => hdo,
    mode    => '0644',
    content => template('hdo/webhooks.json'),
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
    priority      => '10',
    servername    => 'hooks.holderdeord.no',
    serveradmin   => $hdo::params::admin_email,
    template      => 'hdo/apache-webhooks-vhost.conf.erb',
    docroot       => "${root}/public",
    docroot_owner => hdo,
    docroot_group => hdo,
    options       => '-MultiViews -Indexes',
    notify        => Service['httpd'],
    require       => [User['hdo']],
  }

}
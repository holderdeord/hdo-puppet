class nagios::monitor {
  include nagios::base

  file { "${nagios::base::home}/.ssh":
    ensure  => directory,
    owner   => $nagios::base::user,
    mode    => '0600',
    require => User[$nagios::base::user]
  }

  $private_key = "${nagios::base::home}/.ssh/id_rsa"

  file { $private_key:
    ensure  => file,
    owner   => $nagios::base::user,
    mode    => '0600',
    content => hiera('nagios_key', ''),
    require => User[$nagios::base::user]
  }

  package { [ 'nagios3' ]: ensure => installed }

  service { 'nagios3':
    ensure    => running,
    subscribe => [ Package['nagios3'], Package['nagios-plugins'] ],
  }

  # we clear the hosts file to avoid nagios_host bugs (duplicate definitions)
  # see https://github.com/holderdeord/hdo-site/issues/420 and http://projects.puppetlabs.com/issues/11921
  file { 'clear_nagios_hosts':
    path    => '/etc/nagios3/nagios_host.cfg',
    content => '',
    mode    => '0644'
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host    <<||>> { notify => Service['nagios3'], require => File['clear_nagios_hosts'] }
  Nagios_service <<||>> { notify => Service['nagios3'] }

  $htpasswd_path = '/etc/nagios3/htpasswd.users'
  $auth          = hiera('nagios_password', 'hdo123')

  exec { 'create-nagios-htpasswd':
    command   => "htpasswd -b -c ${htpasswd_path} nagiosadmin ${auth}",
    creates   => $htpasswd_path,
    require   => Package['nagios3'],
    logoutput => on_failure
  }

  # puppet's nagios_command type is very buggy (duplicate definitions, wrong permissions), so we set up commands with a template
  # see https://github.com/holderdeord/hdo-site/issues/420

  file { '/etc/nagios-plugins/config/hdo_commands.cfg':
    ensure  => file,
    mode    => '0644',
    content => template('nagios/commands.cfg.erb'),
    require => Package['nagios-plugins']
  }

  #
  # use our custom apache config
  #

  file { '/etc/apache2/conf.d/nagios3.conf':
    ensure => absent
  }

  a2mod { 'rewrite':
    ensure => present
  }

  apache::vhost { 'nagios.holderdeord.no':
    vhost_name    => '*',
    port          => 80,
    priority      => '60',
    servername    => 'nagios.holderdeord.no',
    serveradmin   => 'nagios.holderdeord.no',
    template      => 'nagios/nagios_vhost.conf.erb',
    docroot       => '/usr/share/nagios3/htdocs',
    docroot_owner => 'root',
    docroot_group => 'root',
    notify        => Service['httpd'],
    require       => Package['nagios3'],
  }

}

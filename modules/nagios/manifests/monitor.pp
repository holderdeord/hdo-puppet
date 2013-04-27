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

  # in the VMs, the name appears to be "nagios3"?!
  service { 'nagios':
    ensure    => running,
    subscribe => [ Package['nagios3'], Package['nagios-plugins'] ],
  }

  # collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host    <<||>> { notify => Service['nagios'] }
  Nagios_service <<||>> { notify => Service['nagios'] }

  $htpasswd_path = '/etc/nagios3/htpasswd.users'
  $auth          = hiera('nagios_password', 'hdo123')

  exec { 'create-nagios-htpasswd':
    command   => "htpasswd -b -c ${htpasswd_path} nagiosadmin ${auth}",
    creates   => $htpasswd_path,
    require   => Package['nagios3'],
    logoutput => on_failure
  }

  #
  # TODO(jari): fix permissions on the generated files
  # perhaps not worth using the nagios_command type at all since it's such a hassle
  #

  nagios_command { 'check_over_ssh':
    ensure       => present,
    target       => '/etc/nagios-plugins/config/check_over_ssh.cfg',
    command_line => "/usr/lib/nagios/plugins/check_by_ssh -p 22 -l ${nagios::base::user} -i ${private_key} -t 30 -o StrictHostKeyChecking=no -H \$HOSTADDRESS\$ -C '${nagios::base::home}/nagios.sh'",
    require      => Package['nagios-plugins'],
  }

  nagios_command { 'remote_load':
    ensure       => present,
    target       => '/etc/nagios-plugins/config/remote_load.cfg',
    command_line => "/usr/lib/nagios/plugins/check_by_ssh -p 22 -l ${nagios::base::user} -i ${private_key} -t 30 -o StrictHostKeyChecking=no -H \$HOSTADDRESS\$ -C '/usr/lib/nagios/plugins/check_load -w \$ARG2\$ -c \$ARG3\$'",
    require      => Package['nagios-plugins'],
  }

  nagios_command { 'remote_disk':
    ensure       => present,
    target       => '/etc/nagios-plugins/config/remote_disk.cfg',
    command_line => "/usr/lib/nagios/plugins/check_by_ssh -p 22 -l ${nagios::base::user} -i ${private_key} -t 30 -o StrictHostKeyChecking=no -H \$HOSTADDRESS\$ -C '/usr/lib/nagios/plugins/check_disk -w \$ARG2\$ -c \$ARG3\$ -p \$ARG4\$'",
    require      => Package['nagios-plugins'],
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

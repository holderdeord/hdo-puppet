class postfix(
  $smtp_listen = '127.0.0.1',
  $hostname = $::fqdn,
  $domain = $::domain,
  $network_table_extras = [],
  ) {

  $packages = ['postfix', 'heirloom-mailx']

  package { $packages:
    ensure => installed,
  }

  service { 'postfix':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Package['postfix'],
  }

  file { '/etc/mailname':
    ensure  => present,
    content => "${hostname}\n"
  }

  file { '/etc/postfix/master.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('postfix/master.cf.erb'),
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('postfix/main.cf.erb'),
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  file { '/etc/postfix/network_table':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('postfix/network_table.erb'),
  }

  exec { 'create-aliases-db':
    command => '/usr/bin/newaliases',
    creates => '/etc/aliases.db',
    require => Package['postfix']
  }

  munin::plugin { 'postfix_mailqueue': }
  munin::plugin { 'postfix_mailstats': }
  munin::plugin { 'postfix_mailvolume': }
}

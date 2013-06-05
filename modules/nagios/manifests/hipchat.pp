class nagios::hipchat {
  # assumes the hipchat gem is already installed (required by hdo-deployer)...

  file { '/etc/nagios-plugins/hipchat.rb':
    ensure  => file,
    mode    => '0774',
    owner   => 'nagios',
    group   => 'nagios',
    source  => 'puppet:///modules/nagios/hipchat.rb',
    require => Package['nagios-plugins']
  }


  file { '/etc/nagios-plugins/config/hipchat.cfg':
    ensure  => file,
    content => template('nagios/hipchat-config.erb'),
    mode    => '0644',
    require => Package['nagios-plugins']
  }
}
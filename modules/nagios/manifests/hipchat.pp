class nagios::hipchat {
  # assumes the hipchat gem is already installed (required by hdo-deployer)...

  file { '/etc/nagios-plugins/hipchat.rb':
    ensure  => file,
    mode    => '0744',
    source  => 'puppet:///nagios/hipchat.rb',
    require => Package['nagios-plugins']
  }


  file { '/etc/nagios-plugins/config/hipchat.cfg':
    content => template('nagios/hipchat-config.erb')
    ensure  => file,
    mode    => '0644',
    require => Package['nagios-plugins']
  }
}
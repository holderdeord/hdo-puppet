class nagios::monitor::front {
  $front_hosts = '/etc/nagios3/conf.d/front_hosts.cfg'

  file { $front_hosts:
    ensure => file,
    owner  => root,
    mode   => '0644',
  }

  nagios_host { 'www.holderdeord.no':
    ensure  => present,
    use     => 'generic-host',
    target  => $front_hosts,
  }

  nagios_host { 'holderdeord.no':
    ensure => present,
    use    => 'generic-host',
    target => $front_hosts,
  }

  nagios_service { 'check_http_holderdeord.no':
    check_command       => 'check_http!holderdeord.no',
    use                 => 'generic-service',
    host_name           => 'holderdeord.no',
    notification_period => '24x7',
    service_description => 'holderdeord_check_http',
  }

  nagios_service { 'check_http_www.holderdeord.no':
    check_command       => 'check_http!www.holderdeord.no',
    use                 => 'generic-service',
    host_name           => 'www.holderdeord.no',
    notification_period => '24x7',
    service_description => 'www_check_http',
  }
}
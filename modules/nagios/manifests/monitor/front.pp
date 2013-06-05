class nagios::monitor::front {
  nagios_service { 'check_http_holderdeord.no':
    check_command       => 'check_http!holderdeord.no',
    use                 => 'generic-service',
    host_name           => 'localhost',
    notification_period => '24x7',
    service_description => 'holderdeord_check_http',
  }

  nagios_service { 'check_http_www.holderdeord.no':
    check_command       => 'check_http!www.holderdeord.no',
    use                 => 'generic-service',
    host_name           => 'localhost',
    notification_period => '24x7',
    service_description => 'www_check_http',
  }
}
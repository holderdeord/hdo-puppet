class nagios::target::http {
  @@nagios_service { "check_http_${::hostname}":
    check_command            => "check_http!${::ipaddress}",
    check_interval           => '1',
    use                      => 'generic-service',
    host_name                => $::fqdn,
    notification_period      => '24x7',
    service_description      => "${::hostname}_check_http",
    flap_detection_enabled   => false,
  }
}
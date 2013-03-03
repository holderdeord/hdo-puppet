class nagios::target::http {
  @@nagios_service { "check_http_${::hostname}":
    check_command       => "check_http!${::ipaddress}",
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_http",
  }
}
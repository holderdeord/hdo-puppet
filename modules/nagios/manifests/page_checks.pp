# This class exports nagios host and service check resources
class nagios::page_checks {
  @@nagios_host { "check_http_${::hostname}":
    ensure  => present,
    alias   => "check_http_${::hostname}",
    address => $::ipaddress,
    use     => 'generic-host',
  }

  @@nagios_service { "check_http_${::hostname}":
    check_command       => "check_http -H ${::ipaddress}",
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_http",
  }
}


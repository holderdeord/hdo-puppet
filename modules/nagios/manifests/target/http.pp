class nagios::target::http($auth = undef) {

  $command       = "check_http_${::hostname}"
  $check_command = "check_http!${::ipaddress}"

  if $auth != undef {
    $command       = "check_http_auth_${::hostname}"
    $authParts     = split($auth, ' ')
    $check_command = "check_http_auth!${::ipaddress}!${authParts[0]}!${authParts[1]}"
  }

  @@nagios_service { $command:
    check_command          => $check_command,
    check_interval         => '1',
    use                    => 'generic-service',
    host_name              => $::fqdn,
    notification_period    => '24x7',
    service_description    => "${::hostname}_check_http",
    flap_detection_enabled => false,
  }
}

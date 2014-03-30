# This class exports nagios host and service check resources
class nagios::target(
  $ensure = 'present'
  ) {
  include nagios::base

  @@nagios_host { $::fqdn:
    ensure  => $ensure,
    alias   => $::hostname,
    address => $::ipaddress,
    use     => 'generic-host',
  }

  @@nagios_service { "check_ping_${::hostname}":
    check_command       => 'check_ping!100.0,20%!500.0,60%',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_ping",
    check_interval      => '1',
  }

  @@nagios_service { "check_over_ssh_${::hostname}":
    check_command       => 'check_over_ssh',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_over_ssh",
  }

  #
  # TODO: Extract to a function or class? e.g.
  #
  #   nagios::target::disk(...)
  #
  # Need ability to specify thresholds per host.
  #

  @@nagios_service { "remote_disk_${::hostname}":
    check_command       => 'remote_disk!22!20%!10%!/',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_remote_disk",
  }

  #
  # TODO: Extract to a function or class? e.g.
  #
  #   nagios::target::load(...)
  #
  # Need ability to specify thresholds per host.
  #

  @@nagios_service { "remote_load_${::hostname}":
    check_command       => 'remote_load!22!6.0,4.0,2.0!8.0,4.0,2.0',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_remote_load",
  }
}

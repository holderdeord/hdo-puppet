# This class exports nagios host and service check resources
class nagios::target {

  package { 'nagios-plugins':
    ensure => installed
  }

  file {'/home/hdo/nagioschecks':
    ensure => directory,
  }

  file {'/home/hdo/nagios.sh':
    ensure => present,
    source => 'puppet:///modules/nagios/nagios.sh',
    owner  => 'hdo',
    group  => 'hdo',
    mode   => '0700'
  }

  @@nagios_host { $::fqdn:
    ensure  => present,
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
  }

  @@nagios_service { "check_http_${::hostname}":
    check_command       => "check_http!${::ipaddress}",
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_http",
  }

  @@nagios_service { "check_over_ssh${::hostname}":
    check_command       => 'check_over_ssh',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_check_over_ssh",
  }

  @@nagios_service { "remote_disk_${::hostname}":
    check_command       => 'remote_disk!22!20%!10%!/',
    use                 => 'generic-service',
    host_name           => $::fqdn,
    notification_period => '24x7',
    service_description => "${::hostname}_remote_disk",
  }
}


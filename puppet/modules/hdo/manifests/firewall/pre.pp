class hdo::firewall::pre {
  Firewall {
    require => undef,
  }

  # # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }

  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }

  firewall { '002 accept related established rules':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }

  # firewall { '003 accept all port 80':
  #   proto  => 'tcp',
  #   action => 'accept',
  #   port   => 80
  #  }

  firewall { '003 allow ssh':
    proto  => 'tcp',
    action => 'accept',
    port   => 22
  }

}

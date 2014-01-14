class hdo::puppetmasterd {
  package { ['puppetmaster-passenger']:
    ensure => installed
  }

  class { 'puppetmaster':
    puppetmaster_service_ensure => 'running',
    puppetmaster_service_enable => true,
    puppetmaster_server         => 'puppet.holderdeord.no',
    puppetmaster_certname       => 'puppet.holderdeord.no',
    puppetmaster_report         => true,
    puppetmaster_reports        => 'hipchat',
    puppetmaster_autosign       => false,
    puppetmaster_modulepath     => '/opt/hdo-puppet/modules:/opt/hdo-puppet/third-party',
  }

  file { '/etc/puppet/hipchat.yaml':
    ensure   => file,
    owner    => 'root',
    group    => 'puppet',
    mode     => '0640',
    content  => template('hdo/puppet-hipchat.yaml')
  }
}


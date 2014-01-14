class hdo::puppetmasterd {
  if $::virtual == 'virtualbox' {
    $puppet_server = $::hostname
  } else {
    $puppet_server = 'puppet.holderdeord.no'
  }

  class { 'puppetmaster':
    puppetmaster_service_ensure => 'running',
    puppetmaster_service_enable => true,
    puppetmaster_server         => $puppet_server,
    puppetmaster_certname       => $puppet_server,
    puppetmaster_report         => true,
    puppetmaster_reports        => 'hipchat',
    puppetmaster_autosign       => false,
    puppetmaster_modulepath     => '/opt/hdo-puppet/modules:/opt/hdo-puppet/third-party',
  }

  file { '/etc/puppet/manifests':
    ensure => symlink,
    target => '/opt/hdo-puppet/manifests',
  }

  file { '/etc/puppet/hipchat.yaml':
    ensure   => file,
    owner    => 'root',
    group    => 'puppet',
    mode     => '0640',
    content  => template('hdo/puppet-hipchat.yaml')
  }

  #
  # If this fails, check /var/log/puppetdb/puppetdb.log.
  # You may need to run `puppetdb-ssl-setup` manually...
  #

  class { 'puppetdb':
    database           => 'embedded',
    listen_address     => $puppet_server,
    ssl_listen_address => $puppet_server,
    require            => Class['puppetmaster']
  }

  class { 'puppetdb::master::config':
    puppetdb_server => $puppet_server
  }
}


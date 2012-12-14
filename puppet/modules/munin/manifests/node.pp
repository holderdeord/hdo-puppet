class munin::node(
  $node_package = $munin::params::node_package_name,
) inherits munin::params {

  package { $node_package: }
  Package { ensure => present }

  file { '/etc/munin/munin-node.conf':
    ensure  => present,
    content => template('munin/munin-node.conf')
  }

  file { '/root/bin':
    ensure => directory,
  }

  file { '/root/bin/create_links.sh':
    ensure  => present,
    content => template('munin/create_links.sh.erb'),
    mode    => '0500',
    require => File['/root/bin'],
    before  => Exec['enable_plugins'],
  }

  exec { 'enable_plugins':
    command => '/root/bin/create_links.sh',
  }

}

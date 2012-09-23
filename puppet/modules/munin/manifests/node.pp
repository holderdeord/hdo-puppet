class munin::node(
  $node_package = $munin::params::node_package_name,)
  inherits munin::params {

  define node_packages() {
    package { $node_package:
      ensure => present,
    }  
  }

  define node_config(){
    file {'/etc/munin/munin-node.conf':
      ensure  => present,
      content => template("munin/munin-node.conf") 
    }
    file {'/root/bin':
      ensure => directory,
    } 
    file {'/root/bin/create_links.sh':
      ensure  => present,
      content => template("munin/create_links.sh.erb"),
      mode    => 500,
      require => File['/root/bin'],
    }
    exec {"enable_plugins":
      command => "/root/bin/create_links.sh",
    }
  }

  node_packages{"node_packages":}

  node_config{"node_config":
    require => Node_packages['node_packages'],
  }

}

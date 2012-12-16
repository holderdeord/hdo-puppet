class munin::nginx($listen = '0.0.0.0:80') {
  include munin::node

  file { "${munin::params::plugin_conf_dir}/nginx":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "
[nginx*]
    env.url http://${listen}/nginx_status
    env.ua nginx-status-verifier/0.1
"
  }

  munin::plugin { 'nginx_connection_request':
    source => 'puppet:///modules/munin/nginx_connection_request'
  }

  munin::plugin { 'nginx_memory':
    source => 'puppet:///modules/munin/nginx_memory'
  }

  munin::plugin { 'nginx_request':
    source => 'puppet:///modules/munin/nginx_request'
  }
}
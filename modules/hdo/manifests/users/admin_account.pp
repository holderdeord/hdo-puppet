define hdo::users::admin_account($config) {
  @user { $name:
    ensure     => present,
    home       => "/home/${name}",
    managehome => true,
    shell      => '/bin/bash',
    groups     => 'sudo',
    tag        => 'hdo-admin',
  }

  @ssh_authorized_key { $config[email]:
    ensure => present,
    user   => $name,
    type   => $config[keytype],
    key    => $config[key],
    tag    => 'hdo-admin',
  }
}


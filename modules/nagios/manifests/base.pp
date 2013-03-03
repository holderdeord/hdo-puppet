class nagios::base {
  $user       = 'nagios'
  $home       = "/var/lib/${user}"
  $checks_dir = "${home}/nagioschecks"

  package { 'nagios-plugins':
    ensure => installed
  }

  user { $user:
    ensure     => present,
    home       => $home,
    managehome => true,
    shell      => '/bin/bash',
    groups     => 'adm',
  }

  ssh_authorized_key { "${user}@holderdeord.no":
    ensure  => present,
    user    => $user,
    type    => 'ssh-rsa',
    key     => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCb2guSjvK17Oq1nuLunwVKK4pGUhxyLYdIHjMcZhDBD9RJ3LJL9PUVp9vgZQs8fcZXMJnn85PVRvyvLdqBBwxodDLMNGoh9zEj18tbZuCQ4tweHliubeLf7n7721MQdi8RFW0DJZdyemN5b+WMTM0+UrM0AylOccycLuy+X/iQwxNzUBfyvZ6wd2ypPysnl8NA/j7/QzlMMLXDfKz+pRBmmLG4WHOWVZjyMKFINHuC+2+VXPwMyaPV9924ZUjkHi9oqt6qilg5iMchbqVfE5gbcoWa/P/ELBUiTOHoOEVpx37q4xzb7LaprbBDzspbI5HtYfL5cwrboUJrnwRMeco3',
    require => User[$user]
  }

  file { [$home, $checks_dir]:
    ensure  => directory,
    owner   => $user,
    require => User[$user]
  }

  file { "${home}/nagios.sh":
    ensure  => present,
    source  => 'puppet:///modules/nagios/nagios.sh',
    owner   => $user,
    group   => $user,
    mode    => '0700',
    require => User[$user]
  }
}
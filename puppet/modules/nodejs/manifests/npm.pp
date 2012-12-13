define nodejs::npm(
  $ensure  = present,
  $version = false,
  $global  = true,
) {

  if $global == true {
    $global_flag = '-g'
  } else {
    $global_flag = ''
  }

  if $version == false {
    $package_name = $name
  } else {
    $package_name = "${name}@${version}"
  }

  if $ensure == present {
    exec { "npm-install ${name}":
      command   => "npm ${global_flag} install ${package_name}",
      unless    => "npm ${global_flag} list -p -l | grep '${package_name}'",
      require   => Class['nodejs'],
      logoutput => on_failure,
      tries     => 3,
    }
  } else {
    exec { "npm-remove ${name}":
      command   => "npm ${global_flag} remove ${package_name}",
      onlyif    => "npm ${global_flag} list -p -l | grep '${package_name}'",
      require   => Class['nodejs'],
      logoutput => on_failure,
    }
  }
}
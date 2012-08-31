define ruby::gem($version = false) {
  if $version {
    $install_cmd = "gem1.9.1 install $name --version '$version'"
    $search_cmd  = "gem1.9.1 search -i $name --version '$version' | grep false"
  } else {
    $install_cmd = "gem1.9.1 install $name"
    $search_cmd  = "gem1.9.1 search -i $name | grep false"
  }

  exec { "${name}-gem":
    command   => $install_cmd,
    onlyif    => $search_cmd,
    require   => Package['ruby1.9.1'],
    logoutput => on_failure
  }
}

define ruby::gem {
  exec { "${name}-gem":
    command   => "gem1.9.1 install $name",
    onlyif    => "gem1.9.1 search -i $name | grep false",
    require   => Package["ruby1.9.1"],
    logoutput => on_failure
  }
}

define ruby::gem($version = 'latest') {
  if $version != 'latest' {
    $install_cmd = "bash -l -c 'gem install ${name} --version \'${version}\' --no-rdoc --no-ri'"
    $search_cmd  = "bash -l -c 'gem search -i ${name} --version \'${version}\' | grep false'"
  } else {
    $install_cmd = "bash -l -c 'gem install ${name} --no-rdoc --no-ri'"
    $search_cmd  = "bash -l -c 'gem search -i ${name} | grep false'"
  }

  exec { "rbenv-rehash-for-${name}-${version}":
    command     => 'bash -l -c "rbenv rehash"',
    refreshonly => true,
  }

  exec { "${name}-gem-${version}":
    command   => $install_cmd,
    onlyif    => $search_cmd,
    notify    => Exec["rbenv-rehash-for-${name}-${version}"],
    require   => Class['ruby']
  }
}

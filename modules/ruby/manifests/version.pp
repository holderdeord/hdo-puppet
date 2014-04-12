define ruby::version() {
  $version        = $name
  $global_version = "${ruby::rbenv::dir}/version"

  exec { "install-ruby-${version}":
    command     => "bash -l -c 'rbenv install ${version}'",
    creates     => "${ruby::rbenv::dir}/versions/${version}",
    environment => ["RBENV_ROOT=${ruby::rbenv::dir}", 'CONFIGURE_OPTS=--with-readline-dir=/usr/include/readline'],
    timeout     => 900, # this can take a while in vagrant
    require     => [
      Class['ruby::build'],
      Class['ruby::rbenv'],
      Package[$ruby::deps],
    ]
  }
}

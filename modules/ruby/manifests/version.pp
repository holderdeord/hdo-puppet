define ruby::version() {
  $version        = $name
  $global_version = "${ruby::rbenv_root}/version"

  exec { "install-ruby-${version}":
    command     => "bash -l -c 'rbenv install ${version}'",
    creates     => "${ruby::rbenv_root}/versions/${version}",
    environment => ["RBENV_ROOT=${ruby::rbenv_root}"],
    require     => Class['ruby::build']
  }
}
define elasticsearch::plugin() {
  exec { "install elasticsearch ${name} plugin":
    command     => "/usr/share/elasticsearch/bin/plugin -install ${name}",
    refreshonly => true,
    subscribe   => Class['elasticsearch::install'],
    logoutput   => on_failure,
  }
}
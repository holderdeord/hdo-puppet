class elasticsearch::install(
  $elastic_package = $elasticsearch::params::package,
  $dependencies = $elasticsearch::params::dependencies) inherits elasticsearch::params {

  exec {'elasticsearch-download':
    # need to depend on wget?
    command => "wget https://github.com/downloads/elasticsearch/elasticsearch/${elastic_package} -O /root/${elastic_package}",
    creates => "/root/${elastic_package}",
  }

  package {$dependencies:
    ensure => installed,
  }

  package {$elastic_package:
    ensure   => latest,
    provider => dpkg,
    source   => "/root/${elastic_package}",
    require  => [ Exec['elasticsearch-download'], Package[$dependencies] ],
  }

}

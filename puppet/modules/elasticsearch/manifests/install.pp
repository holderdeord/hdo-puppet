class elasticsearch::install(
  $elastic_package = $elasticsearch::params::package,
  $dependencies = $elasticsearch::params::dependencies) inherits elasticsearch::params {

  notice("elastic_package: $elastic_package")

  package {$dependencies:
    ensure => installed, 
  }

  package {$elastic_package:
    provider => dpkg,
    ensure   => latest,
    source   => "/root/$elastic_package",
    require  => Package[$dependencies],
  }

  file {"/root/$elastic_package":
    ensure => present,
    source => "puppet:///modules/elasticsearch/$elastic_package",
    before => Package[$elastic_package],
  }
}

class elasticsearch::install(
  $elastic_package = $elasticsearch::params::package,
  $dependencies = $elasticsearch::params::dependencies) inherits elasticsearch::params {

  notice("elastic_package: $elastic_package")

  define download() {
    exec {"download":
      command => "wget https://github.com/downloads/elasticsearch/elasticsearch/$elastic_package -O /root/$elastic_package",
    }
  }

  download {"elasticsearch": }

  package {$dependencies:
    ensure => installed, 
  }

  package {$elastic_package:
    provider => dpkg,
    ensure   => latest,
    source   => "/root/$elastic_package",
    #require  => Package[$dependencies],
    require  => [ Download['elasticsearch'], Package[$dependencies] ],

  }

}

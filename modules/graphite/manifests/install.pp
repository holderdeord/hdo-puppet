class graphite::install inherits graphite::params {
  package { $graphite::params::packages:
    ensure => installed,
  }

  file { [$graphite::params::build_dir, $graphite::params::prefix, $graphite::params::root]:
    ensure => directory,
  }

  if ! defined(Package['wget']) {
    package { 'wget':
      ensure => installed,
    }
  }

  $webapp_build_dir  = "${graphite::params::build_dir}/${graphite::params::graphite_version}"
  $carbon_build_dir  = "${graphite::params::build_dir}/${graphite::params::carbon_version}"
  $whisper_build_dir = "${graphite::params::build_dir}/${graphite::params::whisper_version}"

  #
  # whisper
  #

  exec { "download-${graphite::params::whisper_version}":
    command   => "wget -O - '${graphite::params::whisper_dl_url}' | tar zx",
    creates   => $whisper_build_dir,
    cwd       => $graphite::params::build_dir,
    logoutput => on_failure,
    require   => Package['wget'],
  }


  exec { "install-${graphite::params::whisper_version}":
    command     => 'python setup.py install',
    cwd         => $whisper_build_dir,
    creates     => '/usr/local/bin/whisper-create.py',
    require     => Exec["download-${graphite::params::whisper_version}"],
    logoutput   => on_failure,
  }

  #
  # webapp
  #

  exec { "download-${graphite::params::graphite_version}":
    command   => "wget -O - '${graphite::params::webapp_dl_url}' | tar zx",
    creates   => $webapp_build_dir,
    cwd       => $graphite::params::build_dir,
    logoutput => on_failure,
    require   => Package['wget'],
  }

  exec { "check-${graphite::params::graphite_version}-dependencies":
    command     => 'python check-dependencies.py',
    cwd         => $webapp_build_dir,
    refreshonly => true,
    subscribe   => Exec["download-${graphite::params::graphite_version}"],
    logoutput   => on_failure,
  }

  exec { "install-${graphite::params::graphite_version}":
    command     => 'python setup.py install',
    cwd         => $webapp_build_dir,
    refreshonly => true,
    subscribe   => Exec["check-${graphite::params::graphite_version}-dependencies"],
    logoutput   => on_failure,
  }

  #
  # carbon
  #

  exec { "download-${graphite::params::carbon_version}":
    command   => "wget -O - '${graphite::params::carbon_dl_url}' | tar zx",
    creates   => $carbon_build_dir,
    cwd       => $graphite::params::build_dir,
    logoutput => on_failure,
    require   => Package['wget'],
  }

  exec { "install-${graphite::params::carbon_version}":
    command     => 'python setup.py install',
    cwd         => $carbon_build_dir,
    creates     => "${graphite::params::root}/lib/carbon",
    require     => [Exec["download-${graphite::params::carbon_version}"], Exec["install-${graphite::params::whisper_version}"]],
    logoutput   => on_failure,
  }

}

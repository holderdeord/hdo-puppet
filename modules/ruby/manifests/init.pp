class ruby {
  $deps = ['libreadline-dev', 'libssl-dev']

  package { $deps:   ensure => installed }
  package { 'rbenv': ensure => absent    }


  include ruby::rbenv
  include ruby::build

  $base_version = '2.0.0'
  $version      = '2.0.0-p451'

  $binary       = "${ruby::rbenv::dir}/shims/ruby"
  $gems         = "${ruby::rbenv::dir}/versions/${version}/lib/ruby/gems/${base_version}/gems"

  file { "${ruby::rbenv::dir}/global":
    ensure  => file,
    mode    => '0755',
    content => $version,
    require => Ruby::Version[$version],
  }

  ruby::version { $version: }
}

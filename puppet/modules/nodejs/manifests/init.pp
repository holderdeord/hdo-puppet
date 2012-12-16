class nodejs {
  package { ['nodejs', 'npm']: ensure => installed, }

  if ! defined(Package['build-essential']) {
    package { 'build-essential': ensure => installed }
  }
}
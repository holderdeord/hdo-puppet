class hdo::nodejs {
  class { '::nodejs':
    repo_url_suffix     => '6.x',
    manage_package_repo => true,
  }
}
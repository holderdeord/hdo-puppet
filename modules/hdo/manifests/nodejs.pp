class hdo::nodejs {
  class { '::nodejs':
    repo_url_suffix => '6.x',
  }
}
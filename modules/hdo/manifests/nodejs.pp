class hdo::nodejs {
  class { '::nodejs':
    repo_url_suffix => 'node_5.x',
  }
}
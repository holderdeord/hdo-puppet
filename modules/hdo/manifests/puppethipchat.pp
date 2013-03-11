class hdo::puppethipchat {
  file { '/etc/puppet/hipchat.yaml':
    ensure   => file,
    owner    => 'root',
    mode     => '0600',
    content  => template('hdo/puppet-hipchat.yaml')
  }
}
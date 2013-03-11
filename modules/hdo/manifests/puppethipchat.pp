class hdo::puppethipchat {
  file { '/etc/puppet/hipchat.yaml':
    ensure   => file,
    owner    => 'root',
    group    => 'puppet',
    mode     => '0640',
    content  => template('hdo/puppet-hipchat.yaml')
  }
}
class hdo::common {
  include ruby
  include hdo::params

  $home = "/home/${hdo::params::user}"

  package { ['etckeeper', 'vim', 'build-essential', 'git-core', 'emacs23-nox']:
    ensure => installed,
  }

  file { "${home}/.emacs":
    ensure  => file,
    content => '(setq make-backup-files nil)'
  }

  ruby::gem { 'bundler':
    name    => 'bundler',
    version => '>= 1.2.0'
  }

  user { $hdo::params::user:
    ensure     => present,
    home       => $home,
    managehome => true,
    shell      => '/bin/bash',
    groups     => $hdo::params::group
  }

  file { $hdo::params::webapp_root:
    ensure  => 'directory',
    mode    => '0775',
    owner   => 'hdo'
  }

  file { "/home/${hdo::params::user}":
    ensure  => directory,
    owner   => $hdo::params::user,
    require => User[$hdo::params::user],
  }

  ssh_authorized_key { 'jari@holderdeord.no':
    ensure => present,
    user   => $hdo::params::user,
    type   => 'ssh-dss',
    key    => 'AAAAB3NzaC1kc3MAAACBAJqLMUT8klGAt5VEIYAzsCNcG/8FsxBhFuCYSdvf9P5j7I84dOZsmGLHiqxcNEgrXkXMo4smJstYXSSdIVWF+RhSe4P7gH94D78mQS2dfGyXsWsJdqY7obEih76L0HCxhF8fcu4FBBCE3n1cQLfYTqAr6Crm3Rng3mTjUYQ/J8RFAAAAFQDqrN3s3nVO+2Fi6CnRw52IKpBMwQAAAIBTPpoQjYAKMMQuU0mJ/POmH4kzTeCLdyrv8v3pjJ8bOoyF6qMXqRVqlGgKmSEtmSlWD6fmnIyh34c5NiAGaJOySnkLUOLwjUvz2PkJpqazKRa1KkZblg69iKto7IpR2BID3b2gAorpJmNAtexlyn2vTrR3Ai3hCqAGy9rrnkrTEwAAAIAtwepHaG0mGPoYHzkoCNSu6Xzx3mdxFa10CxOj1BXtK5UsVysd5wWOqtYQNq4JZe9mSqk5+KRc1Q2aUAFHCgemMAP2C8RYaT+TiesFs5e+jEFG4HM6T0FDcOV6/+CVwM+IavYRC71ZkE1cM0o9Ycs79h5flNOS7unhSIlIM8OFsg=='
  }

  ssh_authorized_key { 'pere@hungry.com':
    ensure => present,
    user   => $hdo::params::user,
    type   => 'ssh-dss',
    key    => 'AAAAB3NzaC1kc3MAAAEBAIthNgfzBlNTOdlCgKj4RIShPhOelizoj8/fD0xxvYSiErXn4YqxAQ7t4dTFyS6vvgDSXiTo+PgnYUbbNlSkYskX4t6yvCYA2P+hjSIuwzwZgA/xmygjGEAaYlYiWMl4sNdVIf09gd5ae3J/9ik2DoFQM0S9CtbPG7aInJmldK7a5OuiURVFKKziQW+LYMP+4X9CaeTfb7HEhh1HpVl7Evir1MOiejdYPd3SoLfy+DXiQq56p0iHoMQ+x+Vts+dBKy0a9beiT09X6AAYx3QPS5QjrAa9piyZJkn8TN4KkkvBLzHvXTsVKuT44fqZEUi9+UQePG/DInmRvhglu3m644UAAAAVAIq3PB/9XEOTNAAmmFgoELqTgKj9AAABAC91qLKlgh5g6/JwAXPEglbv+2Una3Qm8yx/460oWXiPPfcnjgZ0NwpH3IIGteo9zXFFzcR4+reAFyeDVAXv1bKCr5bYe5XLkKJkNvSg4vpARn5rHwUY4dHc+4xpOnMVGrV3pFGPVgltoW3bUDOrK8VnVo3miyOWgSY/Cqfv90YvY3PhCF1dPfzmbLzvoHAFI2HT0A4iRPiE1taWpEeixOmxYQ9QeY4WXQvb6+kw0a2b2s7DAVSXt8O8CRRuwNmV7ZQvsBcVd1adtzCb1lx91fWBChBOveX1P2lsliwP479A3dg/F8pJpIxmiz1Xc2+wii9AOQtTfIVOAvBHoPU1WK8AAAEAY7io3vbubukSBxAmQ2UN8NvvcgeAt9d1zvggcSoGKk4KLa6ScgUBfvLNeKpM0W7zkaORATpPMEWfGJCLQU++qbHn6usRUB8UGQ3/5f++jyonTbc88fj3SH9v2y+be2sBWyq2Anq3NU1V1QA3og0eqZvha6rB1DPjfBkgd8S6/tZ0opHOTbm8VTRgk/xdjIvZGa9u6zBqXpRkHCFFUsQ6NSLJUs+0+yv2RtmkZ6Iz6QHu3feyJdMJsiFoztYt/7kDSxwoqWUdphoovCCz73ZHX3rIom+MX7qZNaYSKWC37QpGJxofnwQC/PRIIJuSkuqPTzyu6OwNuBia9wCn29wZ4Q=='
  }

  ssh_authorized_key { 'bjorn.dyresen@gmail.com':
    ensure => present,
    user   => $hdo::params::user,
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAsTd38lUZZygRAQKigMb30yW+9CPDJlcYTzLivgE7pcjr5fFMsdcvqJp7raMAFjx8lyf8lljFKnRwPuWMvyUfvxuEyFCUbvgLF8wsSc1lIAsNO0hs5/ejp/ra6LqQ3p3Fz0O2bjd1jQgRu38PPu228ryZHw9jV1cO0Szjxh+S3iqDSU5U9b/HkdHOP8n5b+9YEDSWfePZc8LrE802qb7f43mGs44DX37erq69SrSc05ddlxe13nxIm3DeNlROxZeA02OasnD7DrnLkayYqT9sINn2viajtaWhZIH+C3nua28gygrEUKp333KJjXV4luSzIKUc7zDuxTURAa3E2F9hsw=='
  }

  ssh_authorized_key { 'ops@holderdeord.no':
    ensure => present,
    user   => $hdo::params::user,
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDSYddSmN5x3TOb5y/b1VjM4Kbj+FDtYM/putIEcXCPqlwMu29THjKOqg9FUqj21oRckbPEVMxU+ouKV8Siauz5jcFxcfaJwN39W2yerpNchOKL4v8MYE6mAL4PiYcQhWe4Ynv7n4Ivlk2BpR4mV5qZ4AHHrU7m66ZcBeLkgWtDDSDuXMqT5G0FtZCRQVswu8XV0lOeKe1aEOMJIB4mipIgq8Y7TaN4uN8rpMjGuY34zZOzCp0Uf3KUg2LTn6Mwau5ZDOj9jz+fUixojdbi0J1kf18iL6EQWj5dc2vPpWGessW45VHruCQHnsAdfcXesqqDCRBfUuXG6L4baEHg9tdT'
  }

  file { "${home}/.gemrc":
    ensure  => file,
    owner   => $hdo::params::user,
    mode    => '0644',
    content => 'gem: --no-rdoc --no-ri\n'
  }

  file { '/etc/etckeeper/etckeeper.conf':
    ensure  => file,
    mode    => '0644',
    content => template('hdo/etckeeper.conf'),
    require => Package['etckeeper']
  }
}

class hdo::common {
  include hdo::params

  user { $hdo::params::user:
    ensure     => present,
    home       => "/home/${hdo::params::user}",
    managehome => true,
    shell      => '/bin/bash',
    groups     => $hdo::params::group
  }

  file { "/home/${hdo::params::user}":
    ensure  => directory,
    owner   => $hdo::params::user,
    require => User[$hdo::params::user],
  }

  # Looks like vagrant doesn't create the puppet group by default?
  group { 'puppet':
    ensure => present
  }

  ssh_authorized_key { 'jari@holderdeord.no':
    ensure => present,
    user   => $hdo::params::user,
    type   => 'ssh-dss',
    key    => 'AAAAB3NzaC1kc3MAAACBAJqLMUT8klGAt5VEIYAzsCNcG/8FsxBhFuCYSdvf9P5j7I84dOZsmGLHiqxcNEgrXkXMo4smJstYXSSdIVWF+RhSe4P7gH94D78mQS2dfGyXsWsJdqY7obEih76L0HCxhF8fcu4FBBCE3n1cQLfYTqAr6Crm3Rng3mTjUYQ/J8RFAAAAFQDqrN3s3nVO+2Fi6CnRw52IKpBMwQAAAIBTPpoQjYAKMMQuU0mJ/POmH4kzTeCLdyrv8v3pjJ8bOoyF6qMXqRVqlGgKmSEtmSlWD6fmnIyh34c5NiAGaJOySnkLUOLwjUvz2PkJpqazKRa1KkZblg69iKto7IpR2BID3b2gAorpJmNAtexlyn2vTrR3Ai3hCqAGy9rrnkrTEwAAAIAtwepHaG0mGPoYHzkoCNSu6Xzx3mdxFa10CxOj1BXtK5UsVysd5wWOqtYQNq4JZe9mSqk5+KRc1Q2aUAFHCgemMAP2C8RYaT+TiesFs5e+jEFG4HM6T0FDcOV6/+CVwM+IavYRC71ZkE1cM0o9Ycs79h5flNOS7unhSIlIM8OFsg=='
  }

}

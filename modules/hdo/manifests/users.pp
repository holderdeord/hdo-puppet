class hdo::users {
  include hdo::params

  $users = {
    'jari'   => { email => 'jari@holderdeord.no',     keytype => 'ssh-dss', key => 'AAAAB3NzaC1kc3MAAACBAJqLMUT8klGAt5VEIYAzsCNcG/8FsxBhFuCYSdvf9P5j7I84dOZsmGLHiqxcNEgrXkXMo4smJstYXSSdIVWF+RhSe4P7gH94D78mQS2dfGyXsWsJdqY7obEih76L0HCxhF8fcu4FBBCE3n1cQLfYTqAr6Crm3Rng3mTjUYQ/J8RFAAAAFQDqrN3s3nVO+2Fi6CnRw52IKpBMwQAAAIBTPpoQjYAKMMQuU0mJ/POmH4kzTeCLdyrv8v3pjJ8bOoyF6qMXqRVqlGgKmSEtmSlWD6fmnIyh34c5NiAGaJOySnkLUOLwjUvz2PkJpqazKRa1KkZblg69iKto7IpR2BID3b2gAorpJmNAtexlyn2vTrR3Ai3hCqAGy9rrnkrTEwAAAIAtwepHaG0mGPoYHzkoCNSu6Xzx3mdxFa10CxOj1BXtK5UsVysd5wWOqtYQNq4JZe9mSqk5+KRc1Q2aUAFHCgemMAP2C8RYaT+TiesFs5e+jEFG4HM6T0FDcOV6/+CVwM+IavYRC71ZkE1cM0o9Ycs79h5flNOS7unhSIlIM8OFsg=='},
    'ops'    => { email => 'ops@holderdeord.no',      keytype => 'ssh-dss', key => 'AAAAB3NzaC1kc3MAAACBAMa/a4v1eYW/yk6BBYWmQep05Eh1MwQlo9Mu59+xxYSbvVILApgcQ/bi9fUuiiJAy7ei1Z8rcoDJhn86floWc9PBQCRBbkkg757bYgPxoq/y/+o/tftkt/xc0aJG7N5oSN5GItccX7ELAkpZYNGQXOvshnERFJaSXkKJ3hYY1V6PAAAAFQCd7pEzb2dDdEEUZ3hcLu5d9t5tCQAAAIBBMATAuONDIRhOvSuRvVL8SEIjqMnLUo6rmqSInUid8o2Gcp8ZHqqtPrZ8u79gBtehpmJqKgyZn+sGHw4kmSQhrQT+vBoo9u0xgn0djAvQU09X60Ove3p63SX8zfifyZMj7nRZFOfSgooMV8fO5fMbyKcTNcsLwK+faOmE6KJfCAAAAIBfdFwD5ThIwK+Ea8A6iQCfayG59gUggCBiiYnSzelVuQlDu3Jgnl3kVD+Kp7jjHfNqKUEsYdhBXkWhMkZmF6ChvwtZ5tX418WlBOq76wd/oGENgT/oPlAQ85zUYDELq6Km+XcrTmZT6/q01LleocvfhvNemdIyd7CF8FJxKIYaLw==' },
    'pere'   => { email => 'pere@hungry.com',         keytype => 'ssh-dss', key => 'AAAAB3NzaC1kc3MAAAEBAIthNgfzBlNTOdlCgKj4RIShPhOelizoj8/fD0xxvYSiErXn4YqxAQ7t4dTFyS6vvgDSXiTo+PgnYUbbNlSkYskX4t6yvCYA2P+hjSIuwzwZgA/xmygjGEAaYlYiWMl4sNdVIf09gd5ae3J/9ik2DoFQM0S9CtbPG7aInJmldK7a5OuiURVFKKziQW+LYMP+4X9CaeTfb7HEhh1HpVl7Evir1MOiejdYPd3SoLfy+DXiQq56p0iHoMQ+x+Vts+dBKy0a9beiT09X6AAYx3QPS5QjrAa9piyZJkn8TN4KkkvBLzHvXTsVKuT44fqZEUi9+UQePG/DInmRvhglu3m644UAAAAVAIq3PB/9XEOTNAAmmFgoELqTgKj9AAABAC91qLKlgh5g6/JwAXPEglbv+2Una3Qm8yx/460oWXiPPfcnjgZ0NwpH3IIGteo9zXFFzcR4+reAFyeDVAXv1bKCr5bYe5XLkKJkNvSg4vpARn5rHwUY4dHc+4xpOnMVGrV3pFGPVgltoW3bUDOrK8VnVo3miyOWgSY/Cqfv90YvY3PhCF1dPfzmbLzvoHAFI2HT0A4iRPiE1taWpEeixOmxYQ9QeY4WXQvb6+kw0a2b2s7DAVSXt8O8CRRuwNmV7ZQvsBcVd1adtzCb1lx91fWBChBOveX1P2lsliwP479A3dg/F8pJpIxmiz1Xc2+wii9AOQtTfIVOAvBHoPU1WK8AAAEAY7io3vbubukSBxAmQ2UN8NvvcgeAt9d1zvggcSoGKk4KLa6ScgUBfvLNeKpM0W7zkaORATpPMEWfGJCLQU++qbHn6usRUB8UGQ3/5f++jyonTbc88fj3SH9v2y+be2sBWyq2Anq3NU1V1QA3og0eqZvha6rB1DPjfBkgd8S6/tZ0opHOTbm8VTRgk/xdjIvZGa9u6zBqXpRkHCFFUsQ6NSLJUs+0+yv2RtmkZ6Iz6QHu3feyJdMJsiFoztYt/7kDSxwoqWUdphoovCCz73ZHX3rIom+MX7qZNaYSKWC37QpGJxofnwQC/PRIIJuSkuqPTzyu6OwNuBia9wCn29wZ4Q==' },
    'bjorn'  => { email => 'bjorn.dyresen@gmail.com', keytype => 'ssh-rsa', key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAsTd38lUZZygRAQKigMb30yW+9CPDJlcYTzLivgE7pcjr5fFMsdcvqJp7raMAFjx8lyf8lljFKnRwPuWMvyUfvxuEyFCUbvgLF8wsSc1lIAsNO0hs5/ejp/ra6LqQ3p3Fz0O2bjd1jQgRu38PPu228ryZHw9jV1cO0Szjxh+S3iqDSU5U9b/HkdHOP8n5b+9YEDSWfePZc8LrE802qb7f43mGs44DX37erq69SrSc05ddlxe13nxIm3DeNlROxZeA02OasnD7DrnLkayYqT9sINn2viajtaWhZIH+C3nua28gygrEUKp333KJjXV4luSzIKUc7zDuxTURAa3E2F9hsw=='},
    'yablee' => { email => 'yablee@gmail.com',        keytype => 'ssh-rsa', key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDcv4n9P+oQGoNIGsm7xGzqFYwGElidAdKmqYg8jk5uWLblaBLBjlXWqMSqYFNYk3AQ0ygzmxSeszGYPRI/Zp4+lnq8knG7WAo/PCdo+IrqW0ZXtxzRbqXRq08Itl8anQ5BsTNeYUDNQAV+zq4g9iS4EsjoSBUeE99yAGrO7a5bFfVNet8fljVgT0cRYqs11XZFgSH2Sk9XGmfmfYOU9VUURpB35g/9ZHcKtmYx7pwRPCZGLymjTekawRfOQ8SOmDoNGpc40ZD5m8rZf/YhYzhBCh0EmkzVx5AsoTSga9TqwDscB3DapUiR0NQdBqhLXTEyPSiIxSJsLt75xEG47I8/'},
  }

  #
  # deployers (have access to the 'hdo' user)
  #

  @ssh_authorized_key { "hdo+${users[jari][email]}":
    ensure => present,
    user   => $hdo::params::user,
    type   => $users[jari][keytype],
    key    => $users[jari][key],
    tag    => 'hdo-deployer'
  }

  @ssh_authorized_key { "hdo+${users[yablee][email]}":
    ensure => present,
    user   => $hdo::params::user,
    type   => $users[yablee][keytype],
    key    => $users[yablee][key],
    tag    => 'hdo-deployer'
  }

  @ssh_authorized_key { "hdo+${users[ops][email]}":
    ensure => present,
    user   => $hdo::params::user,
    type   => $users[ops][keytype],
    key    => $users[ops][key],
    tag    => 'hdo-deployer'
  }

  #
  # admins (have their own accounts)
  #

  admin_account { 'jari':   config => $users[jari]   }
  admin_account { 'pere':   config => $users[pere]   }
  admin_account { 'bjorn':  config => $users[bjorn]  }
  admin_account { 'yablee': config => $users[yablee] }
}

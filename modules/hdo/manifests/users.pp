class hdo::users {
  include hdo::params

  $users = {
    'jari'   => { email => 'jari@holderdeord.no',     keytype => 'ssh-rsa', key => 'AAAAB3NzaC1yc2EAAAADAQABAAACAQDEk6UVrjMoUoPAx6u09ldbwaNE7BrYNmW+hg3y7dhM0x6gKgotDFbmUDjpGrkl4Cd6SwpmuKbb7To3vbH1b1NpCO8jOOWT/XBXME8D7D7/j0KUVb10ydhlJDaK2PhMYBrybfThdrLBxpjbn4N09GnnXBhh8bQwHQ5DHuym6tMYsnBvezHwMM3CPzCnnL0gPhS1bvgz2JMx09VpDsoie21Swa8eUs+k/qcT8LIw6u8Vfo8mvhIyaQT8JNnehdF5oMnRpV12uzNqrm4BEflDPWN6PVG7+b7p9mMcIfn3j1++RcJNs4eCBM9WjFRCD+gsTX78ELFCeD9rPLnqqsMIzoJPCeXYVL90FQhdUFaT9M/4I5wO9MjSnw5uHHFnC2CEn466wzurlbrvmMi/Hd/fWx14hg44xPm7h4gBLpl6OSF/sc+kNhKLgtTtPDvnDhRSAvnmBWqWYztoMp++UoxJuZqYaWjs5JpNBiE5yN8fVURMaDQMyRjdZs/cggzU3YDgaBUUkC8bqcKQdO/sgG1IwGffIKexTi6D/rmqkbiojL9iOxRjGsVMMzPDZ2O1jtSnz2+nuwO8Ute1O6m9Iyu4liWXcl1cVbE2CU/FMMcB5/SXLGGLLinzEzOctiXmuJI5QasjioKTTwd5bT5wN+VyMaVN1f7u4SZZ+bDaRbfp67dXJw=='},
    'ops'    => { email => 'ops@holderdeord.no',      keytype => 'ssh-dss', key => 'AAAAB3NzaC1kc3MAAACBAPdUYbDr54MnjTAiZp8tD0cO0XP1hhTStmJzbHwLFA7EQMZwXIxHZjnmaHR8jhUcNcmxaI99Dg2pXUjFLnmscSHrI+pVEyLbXx/eFmus23OTYX+KY1PZ91QZm7RCcgm9dwWxh1Z8s9E0uuwoh6hBpIWoUtaKGIdinD9/ZTZuEYAfAAAAFQDPCmS3wqk2tVkzTW5XJasRU5BMMQAAAIBAVK2yZQKvNlPCLbnOLrrbhF5avmUk7FvpZvQVnV8/wcg57AN+sxU96rm9ulfKVGmNSrrCjXgevCJwew7RWyf2GMs0Fu/lCEFTsQ0zKUL9W/Gz9qqHiM8+ZjKUvnjvfHQ33BMeNFZ+6ej/mfr7IdrFid2plPbZEpYdPy2Q3HfIUAAAAIBIZgzQnB+Ef+5JP1JgiIRbXofPLF+tAkXV/BQKCQxjyKcdp33dXPe2XwURVtI9WQYONR9uAKEuon0BXv3q1sbeYwNTy8zDTRMosnTtA/QrOKbBvpOmwdFIOGNHyYz1S0y88y1HgT0GURup2IozbHXmF6oHVs+/a7VKMFfsTwuQbw==' },
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

  file { "${hdo::params::home}/.ssh/id_dsa":
    ensure  => file,
    owner   => $hdo::params::user,
    mode    => '0600',
    content => hiera('hdo_user_key')
  }
}

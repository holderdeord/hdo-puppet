#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=NOPASSWD: ALL" >> /etc/sudoers

# public ssh key for vagrant user
if false; then
    sshkeyurl="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
    mkdir /home/vagrant/.ssh
    wget -O /home/vagrant/.ssh/authorized_keys $sshkeyurl
    chmod 755 /home/vagrant/.ssh
    chmod 644 /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
fi

# speed up ssh
echo "UseDNS no" >> /etc/ssh/sshd_config

# display login prompt after boot
sed "s/quiet splash//" /etc/default/grub > /tmp/grub
mv /tmp/grub /etc/default/grub
update-grub

(
  cd /var/lib
  git clone https://github.com/holderdeord/hdo-puppet/
  (cd hdo-puppet ; git submodule update --init)
  chown -R vagrant:vagrant hdo-puppet
  puppet apply --modulepath=/var/lib/hdo-puppet/puppet/modules/ \
      /var/lib/hdo-puppet/puppet/site.pp
)

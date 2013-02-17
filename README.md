Holder de Ord VM setup repository
=================================

[![Build Status](https://secure.travis-ci.org/holderdeord/hdo-puppet.png)](http://travis-ci.org/holderdeord/hdo-puppet)

### Installing Vagrant

Full tutorial about Vagrant can be found at http://devops.me/2011/10/05/vagrant/

    $ sudo apt-get install vagrant

or:

    $ [sudo] gem install vagrant

Note that the `hdo-devel` VM image *requires at least Virtualbox 4.1.16*.
For installation instructions, see [this link](http://www.ubuntugeek.com/virtualbox-4-1-16-released-and-ubuntu-installation-instructions-included.html).

### Bring up the VM instance

After the inital checkout of the repo, you need check out the required submodules:

    $ git submodule init
    $ git submodule update

Configure what you want to run on the VM:

    $ cp puppet/vagrant.pp.example puppet/vagrant.pp

After this, bringing up the VM is pretty simple (but can take some time depending on your hardware):

    $ vagrant up

The first time you run this, Vagrant will download a pre-packaged VM image (`hdo-devel.box`).

On subsequent runs, this brings up the VM, sets up port forwarding/shared folders (as configured in the `Vagrantfile`),
and provisions the VM with Puppet.

If you just want to provision an already running VM:

    $ vagrant provision

### Puppet code style

To ensure a consistent code style we use the [puppet-lint](https://github.com/rodjek/puppet-lint) tool.
The `lint.sh` script included in the repo will lint only the modules we maintain, and is used on [Travis CI](http://travis-ci.org/holderdeord/hdo-puppet).

The tool requires a Ruby install + the puppet-lint gem:

    $ [sudo] gem install puppet-lint
    $ bin/lint.sh

### Dependencies

We currently manage dependencies using git submodules. To add a new dependency:

1. `git submodule add [repository] puppet/modules/<name>`
2. Edit `bin/lint.sh` to exclude the new repo.

### Test the configuration

#### Automatically

The `test.sh` script can do this for you. By default, it will destroy and
recreate the VM, provision it, set up password-less login, and do a cold deploy of the app (assumed to be in `../hdo-site`):

    $ bin/test.sh

If you want to skip the re-creation of the VM (i.e you've already done a cold deploy):

    $ DEPLOY_ONLY=1 bin/test.sh

#### Manually

Check out the main website code repository:

    $ git checkout https://github.com/holderdeord/hdo-site.git ../hdo-site

Bring up the VM instance:

    $ vagrant up

Set up password-less logins as `hdo` user, which is needed for Capistrano deployment.
The password for these commands is 'vagrant':

    $ cat ~/.ssh/id_dsa.pub | ssh -p 2222 vagrant@localhost "cat > ./key; sudo mkdir -p /home/hdo/.ssh; sudo mv ./key /home/hdo/.ssh/authorized_keys; sudo chown -R hdo:hdo /home/hdo/.ssh"

Launch the installation of the actual `hdo-site` code:

    $ cd ../hdo-site
    $ bundle install
    $ cap vagrant deploy:setup deploy:cold # only needed first time
    $ cap vagrant deploy

### Production

#### Puppetmaster

TODO (Bjørn?): Describe how to set up the puppetmaster.

##### Hiera

Once the puppetmaster is running, add [Hiera](http://projects.puppetlabs.com/projects/hiera):

```console
$ cat > /etc/puppet/hiera.yaml
---
:hierarchy:
  - '%{hostname}'
  - common

:logger: console

:backends:
  - yaml

:yaml:
  :datadir: '/etc/puppet/hieradata'
^D
$ mkdir /etc/puppet/hieradata
```

Special configuration that shouldn't be checked into version control can now be added to `/etc/puppet/hieradata/%{hostname}.yaml`. After creating these,
the permission should be writable by root and readable by the puppet group:

    $ chown root:puppet /etc/puppet/hieradata/*
    $ chmod 0640 /etc/puppet/hieradata/*

#### Setting up agent on a new server

Install Puppet >= 3.0:

    $ wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
    $ dpkg -i puppetlabs-release-precise.deb
    $ apt-get update
    $ apt-get install puppet

Configure the node to talk to the puppetmaster by adding the following to /etc/puppet/puppet.conf:

    [agent]
    server = puppet.holderdeord.no
    pluginsync = true

Then do the sign the SSL certificate as described [here](http://docs.puppetlabs.com/learning/agent_master_basic.html).

### Creating the Vagrant .box image

If you can find a vagrant base box on www.vagrantbox.es, then
it's quite easy. Unfortunately, there is none available (at least
as of July 2012), so I had to build a custom image based on
Ubuntu 12.04 server LTS i386.

That's the image I was referring to earlier in this document
when I talked about `hdo-devel.box` or `hdo-devel`.

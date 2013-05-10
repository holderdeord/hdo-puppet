HDO server setup
================

[![Build Status](https://secure.travis-ci.org/holderdeord/hdo-puppet.png)](http://travis-ci.org/holderdeord/hdo-puppet)

### Getting started

You need Ruby/Rubygems installed. Then simply run:

    $ script/bootstrap

To get familiar with our setup, look at [nodes.pp](manifests/nodes.pp)

### Puppet code style

To ensure a consistent code style we use [puppet-lint](https://github.com/rodjek/puppet-lint).
This is also part of the [Travis CI](http://travis-ci.org/holderdeord/hdo-puppet) build.

To run syntax check + lint, use:

    $ script/lint

### Dependencies

Dependencies are managed using [librarian-puppet](https://github.com/rodjek/librarian-puppet).

To update a dependency, edit the [Puppetfile](Puppetfile), then run:

  $ script/bootstrap

Note: After pulling down changes to the server running the puppetmaster, always run `script/bootstrap` and restart the puppetmaster (e.g. `service puppetmaster restart`).


### Testing with Vagrant

Install Vagrant from [http://vagrantup.com]. We're using a [multi-VM setup](http://docs.vagrantup.com/v1/docs/multivm.html) to more closely emulate the production environment.
The VMs have their [own node definitions](manifests/vagrant.pp), and can be brought up or destroyed independently:

    $ vagrant up <name>
    $ vagrant destroy <name>

E.g.

    $ vagrant up ops
    $ vagrant up cache
    $ vagrant up app
    $ vagrant up es
    $ vagrant up db

Check out the [Vagrantfile](Vagrantfile) to see how the VMs are set up.

If you just want to provision an already running VM:

    $ vagrant provision <name>

### Deploying hdo-site to Vagrant

Check out the main website code repo:

    $ git checkout https://github.com/holderdeord/hdo-site.git ../hdo-site

Configure manifests/vagrant.pp with the necessary dependencies, then bring up the VM instance:

    $ vagrant up app

Set up password-less logins as `hdo` user, which is needed for Capistrano deployment.
The password for these commands is 'vagrant':

    $ cat ~/.ssh/id_dsa.pub | ssh vagrant@192.168.1.12 "cat > ./key; sudo mkdir -p /home/hdo/.ssh; sudo mv ./key /home/hdo/.ssh/authorized_keys; sudo chown -R hdo:hdo /home/hdo/.ssh"

Deploy hdo-site:

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

[This script](https://gist.github.com/jarib/ed769214bac6a10a12b0) automates the process below.

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

#### PostgreSQL replication

When setting up the secondary DB, initiate base backup with:

    $ sudo su - postgres
    $ pg_basebackup -D /var/lib/postgresql/9.1/main/ -x -h $MASTER_IP -U postgres

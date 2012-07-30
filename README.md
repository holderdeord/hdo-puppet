"Holder de Ord" VM setup repository
===================================

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
    $ ./lint.sh

### Test the configuration

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
    $ VAGRANT=1 cap deploy:setup deploy:cold # only needed first time
    $ VAGRANT=1 cap deploy

The test script can do this for you. By default, it will destroy and
recreate the VM, provision it, set up password-less login, and do a cold deploy of the app (assumed to be in `../hdo-site`):

    $ bin/test.sh

If you want to skip the re-creation of the VM (i.e you've already done a cold deploy):

    $ DEPLOY_ONLY=1 bin/test.sh

### Installation on production servers

*UNTESTED, from Salve's earlier work*:

    $ wget http://apt.puppetlabs.com/puppetlabs-release_1.0-3_all.deb
    $ dpkg -i puppetlabs-release_1.0-3_all.deb
    $ apt-get update
    $ apt-get install puppet git-core
    $ git clone git://github.com/holderdeord/hdo-puppet.git
    $ cd hdo-puppet
    $ git submodule update --init
    $ FACTER_mysql_root_password=t0ps3cret FACTER_mysql_hdo_password=s3cr3t puppet apply --modulepath=puppet/modules puppet/base.pp

### Creating the Vagrant .box image

If you can find a vagrant base box on www.vagrantbox.es, then
it's quite easy. Unfortunately, there is none available (at least
as of July 2012), so I had to build a custom image based on
Ubuntu 12.04 server LTS i386.

That's the image I was referring to earlier in this document
when I talked about `hdo-devel.box` or `hdo-devel`.

----

*FOLLOWING INFORMATION REFERS TO SQUEEZE, SO IT'S OUTDATED*:

You can follow this tutorial: http://vagrantup.com/v1/docs/base_boxes.html

If you create a Virtualbox image named "HDO-Dev-Squeeze", you can recreate
the vagrant .box image with the following commands:

 $ vagrant box remove hdo-squeeze32
 $ vagrant package --output ../hdo-squeeze32.box --base ~/VirtualBox\ VMs/HDO-Dev-Squeeze/HDO-Dev-Squeeze.vbox

...and then go to the Development VM image setup step above.

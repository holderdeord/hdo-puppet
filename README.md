"Holder de Ord" VM setup repository
============================================

### Development VM image setup

Full tutorial about Vagrant can be found at http://devops.me/2011/10/05/vagrant/

    $ sudo apt-get install vagrant

or:

    $ sudo gem install vagrant

And then to add the VM template to Vagrant (one time only operation):

    $ vagrant box add hdo-devel <path-to-hdo-devel.box>

`hdo-devel.box` is the pre-packaged VM image for vagrant that should have
been given to you already. If you don't have it, the process becomes much
more complicated.

In addition, *this image requires Virtualbox 4.1.16*.
For installation instructions, see [this link](http://www.ubuntugeek.com/virtualbox-4-1-16-released-and-ubuntu-installation-instructions-included.html).

### Bring up the VM instance

Should be really simple. It takes time though:

    $ vagrant up

This will also start the provisioning process, that uses
puppet to install most requirements, web server, etc...

### Test the configuration

Check out the main website code repository:

    $ git checkout https://github.com/holderdeord/hdo-site.git ../hdo-site

Initialize and checkout the required submodules:

    $ git submodule init
    $ git submodule update

Bring up the VM instance:

    $ vagrant up

Install the `hdo` user and setup password-less logins as `hdo` user:

    $ ssh -p 2222 vagrant@localhost "sudo mkdir -p /home/hdo/.ssh"
    $ cat ~/.ssh/id_dsa.pub | ssh -p 2222 hdo@localhost "cat >> ~/.ssh/authorized_keys"

Launch the installation of the actual `hdo-site` code:

    $ cd ../hdo-site
    $ bundle install
    $ VAGRANT=1 cap deploy

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

Vagrant::Config.run do |config|
  config.vm.host_name = "hdo-devel"
  config.vm.box       = "hdo-devel-3"
  config.vm.box_url   = "http://files.holderdeord.no/dev/setup/hdo-devel-3.box"

  # web
  config.vm.forward_port 80, 8585
  # varnish
  config.vm.forward_port 6081, 6081
  # statsd
  config.vm.forward_port 8125, 8125, :protocol => "udp"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet"
    puppet.module_path    = "puppet/modules"
    puppet.manifest_file  = "vagrant.pp"

    puppet.options = '--show_diff'
    puppet.options << ' --verbose --debug' if ENV['DEBUG']
    puppet.options << ' --noop' if ENV['NOOP']
  end
end

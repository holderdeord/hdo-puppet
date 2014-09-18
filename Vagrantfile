Vagrant.configure("2") do |config|
  default_box     = 'hdo-devel-3'
  default_box_url = "http://files.holderdeord.no/dev/setup/hdo-devel-3.box"

  config.vm.define :ops do |ops|
    ops.vm.host_name = 'hdo-ops-vm'

    ops.vm.box       = default_box
    ops.vm.box_url   = default_box_url

    ops.vm.network 'private_network', ip: "192.168.1.10"
  end

  config.vm.define :app do |app|
    app.vm.host_name = 'hdo-app-vm'

    app.vm.box       = default_box
    app.vm.box_url   = default_box_url

    app.vm.network 'private_network', ip: '192.168.1.11'
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path    = %w[modules third-party]
    puppet.manifest_file  = "vagrant.pp"

    puppet.options = '--show_diff'
    puppet.options << ' --verbose --debug --trace' if ENV['DEBUG']
    puppet.options << ' --noop' if ENV['NOOP']
    puppet.options << ' --graph' if ENV['GRAPH']
  end
end

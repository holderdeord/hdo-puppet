Vagrant.configure("2") do |config|
  default_box     = 'ubuntu/trusty64'

  config.vm.provider 'virtualbox' do |vm|
    vm.memory = 2048
  end

  config.vm.define :ops do |ops|
    ops.vm.host_name = 'hdo-ops-vm'

    ops.vm.box = default_box

    ops.vm.network 'private_network', ip: "192.168.1.10"
  end

  config.vm.define :app do |app|
    app.vm.host_name = 'hdo-app-vm'

    app.vm.box = default_box

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

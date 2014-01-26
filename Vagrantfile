Vagrant.configure("2") do |config|
  default_box     = 'hdo-devel-3'
  default_box_url = "http://files.holderdeord.no/dev/setup/hdo-devel-3.box"

  config.vm.define :ops do |ops|
    ops.vm.host_name = 'hdo-ops-vm'

    ops.vm.box       = default_box
    ops.vm.box_url   = default_box_url

    ops.vm.network 'private_network', ip: "192.168.1.10"
  end

  config.vm.define :files do |files|
    files.vm.host_name = 'hdo-files-vm'

    files.vm.box       = default_box
    files.vm.box_url   = default_box_url

    files.vm.network 'private_network', ip: '192.168.1.11'
  end

  config.vm.define :app do |app|
    app.vm.host_name = 'hdo-app-vm'

    app.vm.box       = default_box
    app.vm.box_url   = default_box_url

    app.vm.network 'private_network', ip: '192.168.1.12'
  end

  config.vm.define :db1 do |db|
    db.vm.host_name = "hdo-db1-vm"

    db.vm.box       = default_box
    db.vm.box_url   = default_box_url

    db.vm.network 'private_network', ip: '192.168.1.13'
  end

  config.vm.define :db2 do |db|
    db.vm.host_name = "hdo-db2-vm"

    db.vm.box       = default_box
    db.vm.box_url   = default_box_url

    db.vm.network 'private_network', ip: '192.168.1.14'
  end

  config.vm.define :es1 do |es|
    es.vm.host_name = "hdo-es1-vm"

    es.vm.box       = default_box
    es.vm.box_url   = default_box_url

    es.vm.network 'private_network', ip: '192.168.1.15'
  end

  config.vm.define :es2 do |es|
    es.vm.host_name = "hdo-es2-vm"

    es.vm.box       = default_box
    es.vm.box_url   = default_box_url

    es.vm.network 'private_network', ip: '192.168.1.16'
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path    = %w[modules third-party]
    puppet.manifest_file  = "vagrant.pp"

    puppet.options = '--show_diff'
    puppet.options << ' --verbose --debug' if ENV['DEBUG']
    puppet.options << ' --noop' if ENV['NOOP']
  end
end

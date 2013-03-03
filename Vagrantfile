Vagrant::Config.run do |config|
  default_box     = 'hdo-devel-3'
  default_box_url = "http://files.holderdeord.no/dev/setup/hdo-devel-3.box"

  config.vm.define :ops do |ops|
    ops.vm.host_name = "hdo-ops-vm"

    ops.vm.box       = default_box
    ops.vm.box_url   = default_box_url

    ops.vm.network :hostonly, "192.168.1.10"
  end

  config.vm.define :cache do |cache|
    cache.vm.host_name = "hdo-cache-vm"

    cache.vm.box       = default_box
    cache.vm.box_url   = default_box_url

    cache.vm.network :hostonly, "192.168.1.11"
  end

  config.vm.define :app do |app|
    app.vm.host_name = "hdo-app-vm"

    app.vm.box       = default_box
    app.vm.box_url   = default_box_url

    app.vm.network :hostonly, "192.168.1.12"
  end

  config.vm.define :db do |db|
    db.vm.host_name = "hdo-db-vm"

    db.vm.box       = default_box
    db.vm.box_url   = default_box_url

    db.vm.network :hostonly, "192.168.1.13"
  end

  config.vm.define :es do |es|
    es.vm.host_name = "hdo-es-vm"

    es.vm.box       = default_box
    es.vm.box_url   = default_box_url

    es.vm.network :hostonly, "192.168.1.14"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path    = %w[modules third-party]
    puppet.manifest_file  = "vagrant.pp"

    puppet.options = '--storeconfigs --show_diff'
    puppet.options << ' --verbose --debug' if ENV['DEBUG']
    puppet.options << ' --noop' if ENV['NOOP']
  end
end

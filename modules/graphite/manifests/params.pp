class graphite::params {
  $packages = [
    'python-cairo',
    'python-twisted',
    'python-django',
    'python-django-tagging',
    'python-ldap',
    'python-memcache',
    'python-sqlite',
    'python-simplejson'
  ]

  $build_dir        = '/tmp/graphite-build'
  $prefix           = '/opt'
  $root             = "${prefix}/graphite"
  $docroot          = "${root}/webapp"
  $storageroot      = "${root}/storage"
  $owner            = 'www-data'
  $auth             = hiera('basic_auth', 'hdo hdo')
  $htpasswd_path    = '/etc/apache2/graphite.htpasswd'
  $interface        = '0.0.0.0'

  $graphite_version = 'graphite-web-0.9.10'
  $carbon_version   = 'carbon-0.9.10'
  $whisper_version  = 'whisper-0.9.10'

  $webapp_dl_url    = "http://launchpad.net/graphite/0.9/0.9.10/+download/${graphite_version}.tar.gz"
  $webapp_dl_loc    = "${build_dir}/graphite-web.tar.gz"

  $whisper_dl_url   = "http://launchpad.net/graphite/0.9/0.9.10/+download/${whisper_version}.tar.gz"
  $whisper_dl_loc   = "${build_dir}/whisper.tar.gz"

  $carbon_dl_url    = "http://launchpad.net/graphite/0.9/0.9.10/+download/${carbon_version}.tar.gz"
  $carbon_dl_loc    = "${build_dir}/carbon.tar.gz"
}
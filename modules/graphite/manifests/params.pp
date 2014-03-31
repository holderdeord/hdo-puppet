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

  $base_version     = '0.9'
  $version          = '0.9.12'

  $graphite_version = "graphite-web-${version}"
  $carbon_version   = "carbon-${version}"
  $whisper_version  = "whisper-${version}"

  $build_dir        = "/tmp/graphite-build-${version}"
  $prefix           = '/opt'
  $root             = "${prefix}/graphite"
  $docroot          = "${root}/webapp"
  $storageroot      = "${root}/storage"
  $owner            = 'www-data'
  $auth             = hiera('basic_auth', 'hdo hdo')
  $htpasswd_path    = '/etc/apache2/graphite.htpasswd'
  $interface        = '0.0.0.0'

  $webapp_dl_url    = "https://github.com/graphite-project/graphite-web/archive/${version}.tar.gz"
  $webapp_dl_loc    = "${build_dir}/graphite-web.tar.gz"

  $whisper_dl_url   = "https://github.com/graphite-project/whisper/archive/${version}.tar.gz"
  $whisper_dl_loc   = "${build_dir}/whisper.tar.gz"

  $carbon_dl_url    = "https://github.com/graphite-project/carbon/archive/${version}.tar.gz"
  $carbon_dl_loc    = "${build_dir}/carbon.tar.gz"
}

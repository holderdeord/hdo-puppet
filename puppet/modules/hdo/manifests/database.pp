class hdo::database {

  include hdo::common

  # TODO Move out users/passwords and DB creation from puppet?
  #      maybe we should do this within the app deployment part...

  if $postgresql_root_password {} else { $postgresql_root_password = "dont-use-this" }
  if $postgresql_hdo_password  {} else { $postgresql_hdo_password  = "dont-use-this" }

  class { 'postgresql::server':
    config_hash => {
        'postgres_password' => $postgresql_root_password,
    },

    # no idea why this is necessary - either the module isn't properly tested on ubuntu,
    # or something is non-standard about our VM image.

    service_name     => 'postgresql', # defaults to postgresql-9.1
    service_provider => init          # defaults to upstart
  }

  postgresql::db { "hdo_production":
    user     => 'hdo',
    password => postgresql_password('hdo', $postgresql_hdo_password)
  }

  file { "/home/hdo/.hdo-database-pg.yml":
    owner   => "hdo",
    mode    => '0600',
    # See modules/hdo/templates/database.yml
    content => template("hdo/database.yml"),
    require => File["/home/hdo"]
  }

  #
  # http://blog.gomiso.com/2011/07/28/adventures-in-scaling-part-2-postgresql/
  #
  package { "pgtune":
    ensure => installed
  }

}

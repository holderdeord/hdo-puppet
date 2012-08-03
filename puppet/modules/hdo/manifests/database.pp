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
  }


  postgresql::db { "hdo_production":
    user => 'hdo',
    password => postgresql_password('hdo', $postgresql_hdo_password)
  }

  file { "/home/hdo/.hdo-database.yml":
    owner   => "hdo",
    mode    => '0600',
    # See modules/hdo/templates/database.yml
    content => template("hdo/database.yml"),
    require => File["/home/hdo"]
  }

}

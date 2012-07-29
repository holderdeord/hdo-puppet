class hdo::database {

  include hdo::common

  # TODO Move out mysql users/passwords and DB creation from puppet?
  #      maybe we should do this within the app deployment part...

  if $mysql_root_password {} else { $mysql_root_password = "dont-use-this" }
  if $mysql_hdo_password  {} else { $mysql_hdo_password  = "dont-use-this" }

  class { "mysql::server":
    config_hash => {
      "root_password" => $mysql_root_password,
    }
  }

  mysql::db { "hdo_production":
    user     => "hdo",
    password => $mysql_hdo_password,
    host     => "localhost",
    grant    => ["all"],
  }

  file { "/home/hdo/.hdo-database.yml":
    owner   => "hdo",
    mode    => 0600,
    # See modules/hdo/templates/database.yml
    content => template("hdo/database.yml"),
    require => File["/home/hdo"]
  }

}

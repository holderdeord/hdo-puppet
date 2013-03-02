class elasticsearch {
  include elasticsearch::install
  include elasticsearch::config
  include elasticsearch::service
}

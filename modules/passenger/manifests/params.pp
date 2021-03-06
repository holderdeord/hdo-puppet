class passenger::params {
  $version               = '5.0.13'
  $root                  = "${ruby::gems}/passenger-${version}"
  $ruby                  = $ruby::binary
  $min_instances         = 3
  $max_pool_size         = 10
  $max_instances_per_app = 10 # only running one app
  $pool_idle_time        = 300
}